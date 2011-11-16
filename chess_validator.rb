module Chess
  class Cordinate
    attr_reader :column, :row

    def initialize(column, row)
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

    private
      attr_writer :row, :column

  end

  class Board

    attr_reader :board

    def board
      @board ||= [[],[],[],[],[],[],[],[],[]]
    end

    def initialize
      setup_black
      setup_white
    end

    def reset!
      @board = nil
      setup_black
      setup_white
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
        puts "ILEGAL"
      else
        if piece.movable_to?(move.source, move.destination, self)
          puts "LEGAL"
        else
          puts "ILEGAL"
        end
      end
      move
    end

    def print
      printable = ""
      (0..7).each do |row|
        (0..7).each do |column|
          printable << (board[row][column].nil? ?  '-' : board[row][column].to_s) + " " 
        end
        printable << "\n"
      end
      puts printable
    end

    private

    def setup_white
      (0..7).each do |column|
        board[1][column] = Pawn.new("black") 
      end
      board[0][0] = Rook.new("black") # ROOK
      board[0][1] = Knight.new("black") # KNIGHT
      board[0][2] = Bishop.new("black") # BISHOP
      board[0][3] = King.new("black")
      board[0][4] = Queen.new("black")
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
      board[7][3] = King.new("white")
      board[7][4] = Queen.new("white")
      board[7][5] = Bishop.new("white")
      board[7][6] = Knight.new("white")
      board[7][7] = Rook.new("white")
    end
  end

  

  class Piece
    attr_reader :color

    def initialize(color)
      self.color = color
    end

    def movable_to?(current_position, destination, board)
      (board.empty_cordinates & possible_moves(current_position)).any? { |m| m == destination }
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
    def possible_moves(current_position)
      moves = []
      (0..7).each do |pos|
        moves.push(Cordinate.new(pos, current_position.row))
        moves.push(Cordinate.new(current_position.column, pos))
      end
      moves.reject { |m| m.column == current_position.column && m.row == current_position.row }
      moves
    end
  
    def letter
      "R"
    end

  end

  class Queen < Piece
    def possible_moves(current_position)
      moves = []
      (0..7).each do |pos|
        moves.push(Cordinate.new(pos, current_position.row)) 
        moves.push(Cordinate.new(current_position.column, pos)) 
      end
      # DIAGONAL DIREITA
      (0..7).each do |pos|
        moves.push(Cordinate.new(pos,pos))  
        moves.push(Cordinat.new(pos,8-pos))
      end
      moves.reject { |m| m.column == current_position.column && m.row == current_position.row }
      moves
    end
    
    def letter
      "Q"
    end

  end

  class Bishop < Piece

    def possible_moves(current_position)
      moves = []
      # DIAGONAL DIREITA
      (0..7).each do |pos|
        moves.push(Cordinate.new(pos,pos))  
        moves.push(Cordinat.new(pos,8-pos))
      end
      moves.reject { |m| m.column == current_position.column && m.row == current_position.row }
      moves
    end
    def letter
      "B"
    end
  end

  class King < Piece
    def possible_moves(current_position)
      moves = []
      # PARA CIMA E PARA BAIXO
      moves.push(Cordinate.new(current_position.column, current_position.row+1))
      moves.push(Cordinate.new(current_position.column, current_position.row-1))
      # PARA UM LADO E PARA O OUTRO
      moves.push(Cordinate.new(current_position.column+1, current_position.row))
      moves.push(Cordinate.new(current_position.column-1, current_position.row))
      # NO EIXO DA DIAGONAL DIREITA
      moves.push(Cordinate.new(current_position.column+1, current_position.row+1))
      moves.push(Cordinate.new(current_position.column-1, current_position.row-1))
      # NO EIXO DA DIAGONAL ESQUERDA
      moves.push(Cordinate.new(current_position.column-1, current_position.row+1))
      moves.push(Cordinate.new(current_position.column+1, current_position.row-1))
      moves
    end
    def letter
      "K"
    end
  end

  class Knight < Piece
    def possible_moves(current_position)
      moves = []
      # UP 
      moves.push(Cordinate.new(current_position.column-1, current_position.row+2))
      moves.push(Cordinate.new(current_position.column+1, current_position.row+2))
      # DOWN
      moves.push(Cordinate.new(current_position.column-1, current_position.row-2))
      moves.push(Cordinate.new(current_position.column+1, current_position.row-2))
      # LEFT
      moves.push(Cordinate.new(current_position.column-2, current_position.row+1))
      moves.push(Cordinate.new(current_position.column-2, current_position.row-1))
      # RIGHT
      moves.push(Cordinate.new(current_position.column+2, current_position.row+1))
      moves.push(Cordinate.new(current_position.column+2, current_position.row-1))

      moves
    end
    def letter
      "N"
    end
  end
  class Pawn < Piece
    def possible_moves(current_position)
      moves = []
      # UP 
      if self.color == "black"
        moves.push(Cordinate.new(current_position.column, current_position.row+1))
        moves.push(Cordinate.new(current_position.column, current_position.row+2))
      else
        moves.push(Cordinate.new(current_position.column, current_position.row-1))
        moves.push(Cordinate.new(current_position.column, current_position.row-2))
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
      source = Cordinate.new((parsing[1].bytes.first - 97), 8 - parsing[2].to_i)
      destination = Cordinate.new((parsing[3].bytes.first - 97), 8 - parsing[4].to_i)
      move = new(source, destination)
    end

    def to_s
      source.to_s + " " + destination.to_s
    end

    private

      attr_writer :source, :destination
  end

end



board = Chess::Board.new
board.print
"a2 a3
a2 a4
a2 a5
a7 a6
a7 a5
a7 a4
a7 b6
b8 a6
b8 c6
b8 d7
e2 e3
e3 e2".each_line do |l|
 move = board.move!(l)
 board.reset!
end
