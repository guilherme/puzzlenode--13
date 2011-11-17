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
      unless model
        setup_black
        setup_white
      else
        @board_model = model.clone
        @board = model
      end
    end

    def reset!
      @board = nil
      if @board_model.nil?
        setup_black
        setup_white
      end
    end

    def piece_at(cordinate)
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
    
    def move!(move)
      if move.is_a?(String)
        move = Move.parse(move)
      end
      piece = piece_at(move.source)
      if piece.nil?
#puts "#{move.to_s} ILEGAL"
        puts "ILLEGAL"
      else
        if piece.movable_to?(move.source, move.destination, self)
# puts "#{move.to_s} LEGAL"
         puts "LEGAL"
        else
#  puts "#{move.to_s} ILEGAL"
          puts "ILLEGAL"
        end
      end
      move
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

    private

    def setup_white
      (0..7).each do |column|
        board[1][column] = Pawn.new("black") 
      end
      board[0][0] = Rook.new("black") # ROOK
      board[0][1] = Knight.new("black") # KNIGHT
      board[0][2] = Bishop.new("black") # BISHOP
      board[0][3] = Queen.new("black")
      board[0][4] = King.new("black")
      board[0][5] = Bishop.new("black")
      board[0][6] = Knight.new("black")
      board[0][7] = Rook.new("black")
    end

    def setup_black
      (0..7).each do |column|
        board[6][column] = Pawn.new("white") 
      end
      board[7][0] = Rook.new("white") # ROOK
      board[7][1] = Knight.new("white") # KNIGHT
      board[7][2] = Bishop.new("white") # BISHOP
      board[7][3] = Queen.new("white")
      board[7][4] = King.new("white")
      board[7][5] = Bishop.new("white")
      board[7][6] = Knight.new("white")
      board[7][7] = Rook.new("white")
    end
  end

  module MoveCalculator

    def calculate_moves_to_left(current_position, board)
      moves = []
      position = current_position.clone
      position.step_left!
      unless position.out_of_board?
        while (!position.margin_of_board? && board.piece_at(position).nil?)
          cordinate = position.clone
          moves.push(cordinate)
          position.step_left!
        end
        if !position.out_of_board? && position.margin_of_board? && board.piece_at(position).nil? || !board.piece_at(position).nil?  && board.piece_at(position).color != self.color
          moves.push(position)
        end
      end
      moves
    end
    
    def calculate_moves_to_right(current_position,board)
      moves = []
      position = current_position.clone
      position.step_right!
      unless position.out_of_board?
        while (!position.margin_of_board? && board.piece_at(position).nil?)
          cordinate = position.clone
          moves.push(cordinate)
          position.step_right!
        end
        if !position.out_of_board? && position.margin_of_board? && board.piece_at(position).nil? || !board.piece_at(position).nil?  && board.piece_at(position).color != self.color
          moves.push(position)
        end
      end
      moves
    end

    def calculate_moves_to_up(current_position,board)
      moves = []
      position = current_position.clone
      position.step_up!
      unless position.out_of_board?
        while (!position.margin_of_board? && board.piece_at(position).nil?)
          cordinate = position.clone
          moves.push(cordinate)
          position.step_up!
        end
        if !position.out_of_board? && position.margin_of_board? && board.piece_at(position).nil? || !board.piece_at(position).nil?  && board.piece_at(position).color != self.color
          moves.push(position)
        end
      end
      moves
    end

    def calculate_moves_to_down(current_position,board)
      moves = []
      position = current_position.clone
      position.step_down! 
      unless position.out_of_board?
        while (!position.margin_of_board? && board.piece_at(position).nil?)
          cordinate = position.clone
          moves.push(cordinate)
          position.step_down!
        end
        if !position.out_of_board? && position.margin_of_board? && board.piece_at(position).nil? || !board.piece_at(position).nil?  && board.piece_at(position).color != self.color
          moves.push(position)
        end
      end
      moves
    end

    def calculate_moves_to_left_up_diagonal(current_position,board)
      moves = []
      position = current_position.clone
      position.step_left_up_diagonal!
      unless position.out_of_board?
        while (!position.margin_of_board? && board.piece_at(position).nil?)
          cordinate = position.clone
          moves.push(cordinate)
          position.step_left_up_diagonal!
        end
        if !position.out_of_board? && position.margin_of_board? && board.piece_at(position).nil? || !board.piece_at(position).nil?  && board.piece_at(position).color != self.color
          moves.push(position)
        end
      end
      moves 
    end

    def calculate_moves_to_right_up_diagonal(current_position,board)
      moves = []
      position = current_position.clone
      position.step_right_up_diagonal!
      unless position.out_of_board?
        while (!position.margin_of_board? && board.piece_at(position).nil?)
          cordinate = position.clone
          moves.push(cordinate)
          position.step_right_up_diagonal!
        end
        if !position.out_of_board? && position.margin_of_board? && board.piece_at(position).nil? || !board.piece_at(position).nil?  && board.piece_at(position).color != self.color
          moves.push(position)
        end
      end
      moves
    end

    def calculate_moves_to_left_down_diagonal(current_position, board)
      moves = []
      position = current_position.clone
      position.step_left_down_diagonal!
      unless position.out_of_board?
        while (!position.margin_of_board? && board.piece_at(position).nil?)
          cordinate = position.clone
          moves.push(cordinate)
          position.step_left_down_diagonal!
        end
        if !position.out_of_board? && position.margin_of_board? && board.piece_at(position).nil? || !board.piece_at(position).nil?  && board.piece_at(position).color != self.color
          moves.push(position)
        end
      end
      moves
    end

    def calculate_moves_to_right_down_diagonal(current_position,board)
      moves = []
      position = current_position.clone
      position.step_right_down_diagonal!
      unless position.out_of_board?
        while (!position.margin_of_board? && board.piece_at(position).nil?)
          cordinate = position.clone
          moves.push(cordinate)
          position.step_right_down_diagonal!
        end
        if !position.out_of_board? && position.margin_of_board? && board.piece_at(position).nil? || !board.piece_at(position).nil?  && board.piece_at(position).color != self.color
          moves.push(position)
        end
      end
      moves
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
      (board.empty_cordinates & possible_moves(current_position, board)).any? { |m| m == destination } || (!board.piece_at(destination).nil? && board.piece_at(destination).color != self.color && possible_moves(current_position,board).any? { |m| m == destination })
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
    def possible_moves(current_position, board)
      moves = []
      # PARA CIMA E PARA BAIXO
      position = current_position.clone; position.step_up!
      moves.push(position)
      position = current_position.clone; position.step_down!
      moves.push(position)
      # PARA UM LADO E PARA O OUTRO
      position = current_position.clone; position.step_left!
      moves.push(position)
      position = current_position.clone; position.step_right!
      moves.push(position)
      # NO EIXO DA DIAGONAL DIREITA
      position = current_position.clone; position.step_right_up_diagonal!
      moves.push(position)
      position = current_position.clone; position.step_right_down_diagonal!
      moves.push(position)
      # NO EIXO DA DIAGONAL ESQUERDA
      position = current_position.clone; position.step_left_up_diagonal!
      moves.push(position)
      position = current_position.clone; position.step_left_down_diagonal!
      moves.push(position)

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
      moves = []
      # UP 
      if self.color == "b"
        position = Cordinate.new(current_position.row+1, current_position.column)
        if board.piece_at(position).nil?
          moves.push(position) 
          position = Cordinate.new(current_position.row+2, current_position.column)
          if board.piece_at(position).nil?
            moves.push(position)
          end
        end
      else                                             
        position = Cordinate.new(current_position.row-1, current_position.column)
        if board.piece_at(position).nil?
          moves.push(position) 
          position = Cordinate.new(current_position.row-2, current_position.column)
          if board.piece_at(position).nil?
            moves.push(position)
          end
        end
      end
      # DIAGONAL IF WILL KILL SOMEONE

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

    private

      attr_writer :source, :destination
  end

end




