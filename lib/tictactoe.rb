
require_relative 'board.rb'

puts 'Starting tic-tac-toe...'
puts

players = ['X', 'O']
current_player = players[rand(2)]
b = Board.new(current_player)
b.display()

while not b.full?() and not b.winner()
  b.ask_player_for_move(current_player)
  puts "---------- #{current_player}"
  current_player = b.get_next_turn()
  b.display()
  puts
end

if b.winner()
  puts 'player #{b.get_net_turn()} wins.'
else
  puts 'Tie Game.'
end
puts 'Game Over.'
