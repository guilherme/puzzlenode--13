module Chess
  class Cordinate
    attr_reader :column, :row

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

  

  class Piece
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
      (board.empty_cordinates & possible_moves(current_position)).any? { |m| m == destination } || (!board.piece_at(destination).nil? && board.piece_at(destination).color != self.color && possible_moves(current_position).any? { |m| m == destination })
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
        moves.push(Cordinate.new(current_position.row, pos))
        moves.push(Cordinate.new(pos, current_position.column))
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
        moves.push(Cordinate.new(current_position.row, pos)) 
        moves.push(Cordinate.new(pos, current_position.column)) 
      end
      (0..7).each do |pos|
        # DIAGONAL DIREITA
        moves.push(Cordinate.new(pos,pos))  
        # DIAGONAL ESQUERDA
        moves.push(Cordinate.new(pos,7-pos))
      end
      moves.reject! { |m| m.column == current_position.column && m.row == current_position.row }
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
        moves.push(Cordinate.new(7-pos,pos))
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
      moves.push(Cordinate.new(current_position.row+1,current_position.column))
      moves.push(Cordinate.new(current_position.row-1,current_position.column))
      # PARA UM LADO E PARA O OUTRO
      moves.push(Cordinate.new(current_position.row,current_position.column+1))
      moves.push(Cordinate.new(current_position.row,current_position.column-1))
      # NO EIXO DA DIAGONAL DIREITA
      moves.push(Cordinate.new(current_position.row+1, current_position.column+1))
      moves.push(Cordinate.new(current_position.row-1, current_position.column-1))
      # NO EIXO DA DIAGONAL ESQUERDA
      moves.push(Cordinate.new(current_position.row+1,current_position.column-1))
      moves.push(Cordinate.new(current_position.row-1,current_position.column+1))
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
      moves.push(Cordinate.new(current_position.row+2,current_position.column-1))
      moves.push(Cordinate.new(current_position.row+2,current_position.column+1))
      # DOWN                                           ,                         )
      moves.push(Cordinate.new(current_position.row-2,current_position.column-1))
      moves.push(Cordinate.new(current_position.row-2,current_position.column+1))
      # LEFT                                         ,                         )
      moves.push(Cordinate.new(current_position.row+1,current_position.column-2))
      moves.push(Cordinate.new(current_position.row-1,current_position.column-2))
      # RIGHT                                        ,                         )
      moves.push(Cordinate.new(current_position.row+1,current_position.column+2))
      moves.push(Cordinate.new(current_position.row-1,current_position.column+2))

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
      if self.color == "b"
        moves.push(Cordinate.new(current_position.row+1, current_position.column))
        moves.push(Cordinate.new(current_position.row+2, current_position.column))
      else                                             
        moves.push(Cordinate.new(current_position.row-1, current_position.column))
        moves.push(Cordinate.new(current_position.row-2, current_position.column))
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



=begin
board = Chess::Board.parse!("
bR bN bB bQ bK bB bN bR
bP bP bP bP bP bP bP bP
-- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --
wP wP wP wP wP wP wP wP
wR wN wB wQ wK wB wN wR")
puts board.to_s == "
bR bN bB bQ bK bB bN bR
bP bP bP bP bP bP bP bP
-- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --
wP wP wP wP wP wP wP wP
wR wN wB wQ wK wB wN wR".strip.chomp
puts board.to_s

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
=end

complex_board = Chess::Board.parse!("
bK -- -- -- -- bB -- --
-- -- -- -- -- bP -- --
-- bP wR -- wB -- bN --
wN -- bP bR -- -- -- wP
-- -- -- -- wK wQ -- wP
wR -- bB wN wP -- -- --
-- wP bQ -- -- wP -- --
-- -- -- -- -- wB -- --")
puts complex_board.to_s

"b2 b3 
f2 b7  
b4 a8  
a8 g5  
b2 b4
h7 f6
e3 b1
b7 e4
b2 b5
g7 g2
f7 f8
g7 e8
f5 g5
f7 f6
c3 a2
e1 c1
f7 f5
g8 c6
b2 d5
f7 f4
f6 f3
c5 f4
b6 a5
c3 d7
b2 f6
e4 d8
d2 g6
b2 c3
a3 g5
h6 e8
d3 b5
d6 f3
c5 c4
f6 a3
b7 c1
f1 f1
b6 b4
a7 e5
b6 c5
c2 e7
d4 f5
a7 g8
a7 d1
c5 b4
c4 e3
h4 h3
b5 b2
b2 g4
h3 h4
h8 d3
h8 h7
h2 h3
e8 c4
a3 a1
d3 b5
a3 a1
d5 d3
d5 f5
b4 f6
d5 g2
c8 d4
d5 b5
c6 d5
f3 b5
a1 g6
g6 e5
d3 e6
g6 a7
g6 h4
c6 d8
a3 h8
g8 f8
c7 f2
d3 c4
a5 a4
a5 b5
f1 a8
c2 g1
e5 a4
h5 f1
e6 g4
g5 h2
c3 b2
h2 c7
e6 f3
c3 c4
f1 c4
b3 a6
c4 b3
c1 h6
a5 c5
f4 f7
c2 c6
f6 g2
d2 a1
e4 a3
c2 d3
a8 c6
d6 d1
c2 e4
d6 g2
a6 a7
c2 c4
a8 a7
c4 d3
c3 h5
b4 c7
e6 d5
b6 d6
e5 f8
f1 f6
a8 a6
a8 c6
e4 e5
h2 a5
c8 e1
e3 h2
f3 h3".each_line do |l|
 move = complex_board.move!(l)
 complex_board.reset!
end
