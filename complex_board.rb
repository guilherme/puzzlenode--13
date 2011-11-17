require 'chess_validator'
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
