# -*- coding: utf-8 -*-

require_relative 'board.rb'

puts 'Starting tic-tac-toe...\n'

current_player = Board::PLAYERS[rand(2)]
b = Board.new(current_player)
b.display

until b.full?
  break if b.winner
  b.ask_player_for_move current_player
  puts "---------- #{current_player}"
  current_player = b.next_turn
  b.display
  puts
end

winner = b.winner
puts winner ? "player '#{winner}' wins." : 'Tie Game.'
puts 'Game Over.'
