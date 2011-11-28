module Chess
  class Cordinate
    attr_reader :column, :row

    def margin_of_board?
      column == 0 || row == 0 || column == 7 || row == 7
    end

    def out_of_board?
      column < 0 || row < 0 || column > 7 || row > 7
    end

    def initialize(row, column)
      self.column = column
      self.row    = row
    end

    def ==(cordinate)
      self.row == cordinate.row && self.column == cordinate.column
    end

    def to_s
      "#{(column + 97).chr}#{8 - row}" 
    end

    def eql? other
      other.kind_of?(self.class) && self.column == other.column && self.row == other.row
    end

    def hash
      code = column.hash
      code += row.hash
      code
    end

    def step_right!
      self.column += 1
    end

    def step_left!
      self.column -= 1
    end


    def step_up!
      self.row   += 1
    end

    def step_down!
      self.row   -= 1
    end

    def step_left_up_diagonal!
      self.row    -= 1
      self.column -= 1
    end

    def step_right_up_diagonal!
      self.row    -= 1
      self.column += 1
    end

    def step_left_down_diagonal!
      self.row    +=1
      self.column -=1
    end

    def step_right_down_diagonal!
      self.row    += 1
      self.column += 1
    end


    private
      attr_writer :row, :column

  end

  class Board
    PIECE_MATCHER = /([wb][RBQKNP ]|[-])+/

    attr_reader :board

    def board
      @board ||= @board_model || [[],[],[],[],[],[],[],[],[]]
    end

    def self.parse!(board)
      board_model = [[],[],[],[],[],[],[],[]]
      row = 0
      board.to_s.strip!.chomp!
      board.each_line do |line|
        line.scan(PIECE_MATCHER).each_with_index do |piece_string,column|
          board_model[row][column] = (Piece.parse!(piece_string[0]) rescue nil)
        end
        row += 1
      end
      Board.new(board_model)
    end

    def initialize(model)
      @board_model = model.clone
      @board = model
    end

    def reset!
      @board = nil
    end

    def piece_at(cordinate)
      return nil if cordinate.out_of_board?
      board[cordinate.row][cordinate.column]
    end

    def empty_cordinates
      cordinates = []
      (0..7).each do |row|
        (0..7).each do |column|
          cordinate = Cordinate.new(row,column)
          cordinates << cordinate if piece_at(cordinate).nil?
        end
      end
      cordinates
    end
    
    def to_s
      printable = "    a  b  c  d  e  f  g  h\n"
      (0..7).each do |row|
        printable << "#{8 - row}  "
        (0..7).each do |column|
          printable << (board[row][column].nil? ?  '--' : board[row][column].to_s) + " " 
        end
        printable << "\n"
      end
      printable
    end

  end

  module MoveCalculator


    def move_towards_direction_without_trespass_a_piece(current_position,board, &block)
      moves = []
      position = current_position.clone
      yield position
      unless position.out_of_board?
        while (!position.out_of_board? && board.piece_at(position).nil?)
          cordinate = position.clone
          moves.push(cordinate)
          yield position
        end
        if board.piece_at(position) && board.piece_at(position).color != self.color
          moves.push(position)
        else
          moves.push(position) unless position.out_of_board?
        end
      end
      moves
    end

    def calculate_moves_to_left(current_position, board)
      move_towards_direction_without_trespass_a_piece(current_position, board) { |position| position.step_left! }
    end
    
    def calculate_moves_to_right(current_position,board)
      move_towards_direction_without_trespass_a_piece(current_position, board) { |position| position.step_right! }
    end

    def calculate_moves_to_up(current_position,board)
      move_towards_direction_without_trespass_a_piece(current_position, board) { |position| position.step_up! }
    end

    def calculate_moves_to_down(current_position,board)
      move_towards_direction_without_trespass_a_piece(current_position, board) { |position| position.step_down! }
    end

    def calculate_moves_to_left_up_diagonal(current_position,board)
      move_towards_direction_without_trespass_a_piece(current_position, board) { |position| position.step_left_up_diagonal! }
    end

    def calculate_moves_to_right_up_diagonal(current_position,board)
      move_towards_direction_without_trespass_a_piece(current_position, board) { |position| position.step_right_up_diagonal! }
    end

    def calculate_moves_to_left_down_diagonal(current_position, board)
      move_towards_direction_without_trespass_a_piece(current_position, board) { |position| position.step_left_down_diagonal! }
    end

    def calculate_moves_to_right_down_diagonal(current_position,board)
      move_towards_direction_without_trespass_a_piece(current_position, board) { |position| position.step_right_down_diagonal! }
    end

  end

  

  class Piece
    include MoveCalculator

    attr_reader :color

    def initialize(color)
      self.color = color
    end

    def self.parse!(piece_string)
      color = piece_string[0].chr
      letter  = piece_string[1].chr
      case letter
        when "R"
          Rook.new(color)
        when "Q"
          Queen.new(color)
        when "K"
          King.new(color)
        when "B"
          Bishop.new(color)
        when "P"
          Pawn.new(color)
        when "N"
          Knight.new(color)
        else
          #invalid
          raise "Invalid"
      end
    end

    def movable_to?(current_position, destination, board)
      (board.empty_cordinates & possible_moves(current_position, board)).any? { |m| m == destination } || (possible_moves(current_position,board).any? { |m| m == destination } && !board.piece_at(destination).nil? && board.piece_at(destination).color != self.color)
    end

    def possible_moves(current_position, board)
      []
    end

    def  to_s
      "#{(color[0].chr)}#{letter}"
    end

    private
      attr_writer :color
  end
  
  class Rook < Piece
    def possible_moves(current_position, board)
      moves = []
      # LEFT MOVE
      moves << calculate_moves_to_left(current_position,board)
      # RIGHT MOVE
      moves << calculate_moves_to_right(current_position,board)
      # UP MOVE
      moves << calculate_moves_to_up(current_position,board)
      # DOWN MOVE
      moves << calculate_moves_to_down(current_position,board)


      moves.flatten!
      moves.reject { |m| m.column == current_position.column && m.row == current_position.row }
      moves
    end
  
    def letter
      "R"
    end

  end

  class Queen < Piece
    def possible_moves(current_position, board)
      moves = []

      # LEFT MOVE
      moves << calculate_moves_to_left(current_position,board)
      # RIGHT MOVE
      moves << calculate_moves_to_right(current_position,board)
      # UP MOVE
      moves << calculate_moves_to_up(current_position,board)
      # DOWN MOVE
      moves << calculate_moves_to_down(current_position,board)
      # DIAGONAL ESQUERDA UP
      moves << calculate_moves_to_left_up_diagonal(current_position, board)
      # DIAGONAL DIREITA UP
      moves << calculate_moves_to_right_up_diagonal(current_position, board)
      # DIAGONAL ESQUERDA DOWN
      moves << calculate_moves_to_left_down_diagonal(current_position, board)
      # DIAGONAL DIREITA DOWN
      moves << calculate_moves_to_right_down_diagonal(current_position, board)

      moves.flatten!
      moves.reject! { |m| m.column == current_position.column && m.row == current_position.row }
      moves
    end
    
    def letter
      "Q"
    end

  end

  class Bishop < Piece

    def possible_moves(current_position, board)
      moves = []
      # DIAGONAL ESQUERDA UP
      moves << calculate_moves_to_left_up_diagonal(current_position, board)
      # DIAGONAL DIREITA UP
      moves << calculate_moves_to_right_up_diagonal(current_position, board)
      # DIAGONAL ESQUERDA DOWN
      moves << calculate_moves_to_left_down_diagonal(current_position, board)
      # DIAGONAL DIREITA DOWN
      moves << calculate_moves_to_right_down_diagonal(current_position, board)

      moves.flatten!
      moves.reject { |m| m.column == current_position.column && m.row == current_position.row }
      moves
    end
    def letter
      "B"
    end
  end

  class King < Piece

    def vulnerable?(current_position, board)
      # verifica se existem inimigos
      # <=> nas laterais (Rainha, Torre)
      # LEFT MOVE
      moves = calculate_moves_to_left(current_position,board)
      # RIGHT MOVE
      moves << calculate_moves_to_right(current_position,board)
      if moves.flatten.any? { |cordinate|  board.piece_at(cordinate)  && (board.piece_at(cordinate).is_a?(Queen) || board.piece_at(cordinate).is_a?(Rook)) && board.piece_at(cordinate).color != self.color   }
        return true
      end

      # nas verticais (Rainha, Torre)
      # UP MOVE
      moves = calculate_moves_to_up(current_position,board)
      # DOWN MOVE
      moves << calculate_moves_to_down(current_position,board)
      if moves.flatten.any? { |cordinate|  board.piece_at(cordinate)  && (board.piece_at(cordinate).is_a?(Queen) || board.piece_at(cordinate).is_a?(Rook)) && board.piece_at(cordinate).color != self.color   }
        return true
      end

      # nas diagonais (Peão, Rainha, Bispo)
      if self.color == 'w'
        position = current_position.clone
        position.step_right_up_diagonal!
        moves  = [position]
        position = current_position.clone
        position.step_right_down_diagonal!
        moves.push(position)
        if moves.flatten.any? { |cordinate|  board.piece_at(cordinate)  && (board.piece_at(cordinate).is_a?(Pawn)) && board.piece_at(cordinate).color != self.color   }
          return true
        end
      else
        position = current_position.clone
        position.step_left_up_diagonal!
        moves  = [position]
        position = current_position.clone
        position.step_left_down_diagonal!
        moves.push(position)
        if moves.flatten.any? { |cordinate|  board.piece_at(cordinate)  && (board.piece_at(cordinate).is_a?(Pawn)) && board.piece_at(cordinate).color != self.color   }
          return true
        end
      end


      
      # DIAGONAL ESQUERDA UP
      moves = calculate_moves_to_left_up_diagonal(current_position, board)
      # DIAGONAL DIREITA UP
      moves << calculate_moves_to_right_up_diagonal(current_position, board)
      # DIAGONAL ESQUERDA DOWN
      moves << calculate_moves_to_left_down_diagonal(current_position, board)
      # DIAGONAL DIREITA DOWN
      moves << calculate_moves_to_right_down_diagonal(current_position, board)
      if moves.flatten.any? { |cordinate|  board.piece_at(cordinate)  && (board.piece_at(cordinate).is_a?(Queen) || board.piece_at(cordinate).is_a?(Bishop)) && board.piece_at(cordinate).color != self.color   }
        return true
      end

      # na mira dos cavalos
      knight = Knight.new(self.color)
      if knight.possible_moves(current_position,board).any? { |cordinate| board.piece_at(cordinate)  && board.piece_at(cordinate).is_a?(Knight) && board.piece_at(cordinate).color != self.color  }
        return true
      end
      return false
    end
    def possible_moves(current_position, board)
      moves = []
      # PARA CIMA E PARA BAIXO
      position = current_position.clone; position.step_up!
      moves.push(position) if !position.out_of_board? && !self.vulnerable?(position,board)
      position = current_position.clone; position.step_down!
      moves.push(position) if !position.out_of_board? && !self.vulnerable?(position,board)
      # PARA UM LADO E PARA O OUTRO
      position = current_position.clone; position.step_left!
      moves.push(position) if !position.out_of_board? && !self.vulnerable?(position,board)
      position = current_position.clone; position.step_right!
      moves.push(position) if !position.out_of_board? && !self.vulnerable?(position,board)
#      # NO EIXO DA DIAGONAL DIREITA
      position = current_position.clone; position.step_right_up_diagonal!
      moves.push(position) if !position.out_of_board? && !self.vulnerable?(position,board)
      position = current_position.clone; position.step_right_down_diagonal!
      moves.push(position) if !position.out_of_board? && !self.vulnerable?(position,board)

#     # NO EIXO DA DIAGONAL ESQUERDA
      position = current_position.clone; position.step_left_up_diagonal!
      moves.push(position) if !position.out_of_board? && !self.vulnerable?(position,board)
      position = current_position.clone; position.step_left_down_diagonal!
      moves.push(position) if !position.out_of_board? && !self.vulnerable?(position,board)

      moves
    end
    def letter
      "K"
    end
  end

  class Knight < Piece
    def possible_moves(current_position, board)
      # OK
      moves = []
      # UP 
      position = Cordinate.new(current_position.row+2,current_position.column-1)
      moves.push(position)

      position = Cordinate.new(current_position.row+2,current_position.column+1)
      moves.push(position)
      # DOWN
      position = Cordinate.new(current_position.row-2,current_position.column-1)
      moves.push(position)
      position = Cordinate.new(current_position.row-2,current_position.column+1)
      moves.push(position)
      # LEFT                                         ,                         )
      position = Cordinate.new(current_position.row+1,current_position.column-2)
      moves.push(position)
      position = Cordinate.new(current_position.row-1,current_position.column-2)
      moves.push(position)
      # RIGHT                                        ,                         )
      position = Cordinate.new(current_position.row+1,current_position.column+2)
      moves.push(position)
      position = Cordinate.new(current_position.row-1,current_position.column+2)
      moves.push(position) 

      moves
    end
    def letter
      "N"
    end
  end
  class Pawn < Piece
    def possible_moves(current_position, board)
      # LOOK FOR WRONG MOVES
      moves = []
      # UP 
      if self.color == "b"
        position = current_position.clone; position.step_up!
        if board.piece_at(position).nil? 
          moves.push(position) 
          if current_position.row == 1
            position = current_position.clone; position.step_up!; position.step_up!
            if board.piece_at(position).nil?
              moves.push(position)
            end
          end
        end
        position = current_position.clone; position.step_left_down_diagonal!;
        if board.piece_at(position) && board.piece_at(position).color != self.color
          moves.push(position)
        end
        position = current_position.clone; position.step_right_down_diagonal!;
        if board.piece_at(position) && board.piece_at(position).color != self.color
          moves.push(position)
        end
      else                                             
        position = current_position.clone; position.step_down!
        if board.piece_at(position).nil? 
          moves.push(position) 
          if current_position.row == 6
            position = current_position.clone; position.step_down!; position.step_down!
            if board.piece_at(position).nil?
              moves.push(position)
            end
          end
        end
        position = current_position.clone; position.step_left_up_diagonal!;
        if board.piece_at(position) && board.piece_at(position).color != self.color
            moves.push(position)
        end
        position = current_position.clone; position.step_right_up_diagonal!;
        if board.piece_at(position) && board.piece_at(position).color != self.color
          moves.push(position)
        end
      end

      moves
    end
    def letter
      "P"
    end
  end
   

  
  class Move

    attr_reader :source, :destination
    

    MOVE_REGEXP = /([a-h])([0-8]) ([a-h])([0-8])/


    def initialize(source, destination)
      self.source = source
      self.destination = destination
    end

    def self.parse(move_string)
      parsing = move_string.match(MOVE_REGEXP)
      source = Cordinate.new((8 - parsing[2].to_i),(parsing[1].bytes.first - 97))
      destination = Cordinate.new((8 - parsing[4].to_i), (parsing[3].bytes.first - 97))
      move = new(source, destination)
    end

    def to_s
      source.to_s + " " + destination.to_s
    end

    def legal?(board)
      piece = board.piece_at(source)
      if piece.nil?
        false
      else
        if piece.movable_to?(source, destination, board)
          true
        else
          false
        end
      end
    end

    private

      attr_writer :source, :destination
  end

end
