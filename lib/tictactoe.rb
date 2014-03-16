# -*- coding: utf-8 -*-

require_relative 'board.rb'

puts 'Starting tic-tac-toe...\n'

current_player = rand(2)
current_player = -1 if current_player == 0
b = Board.new(current_player)
b.display

until b.full?
  break if b.winner
  b.ask_player_for_move current_player
  puts "---------- #{Board::PLAYERS[current_player]} : puts #{b.last_pos}"
  current_player = b.next_turn
  b.display
  puts
end

winner = b.winner
puts winner ? "player '#{Board::PLAYERS[winner]}' wins." : 'Tie Game.'
puts 'Game Over.'
