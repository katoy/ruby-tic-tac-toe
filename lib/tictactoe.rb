# -*- coding: utf-8 -*-

require_relative 'board.rb'

def one_play(first_player)
  b = Board.new(first_player).display

  current_player = first_player
  until b.full? || b.winner
    b.ask_player_for_move current_player
    puts "---------- #{Board::PLAYERS[current_player]} : puts #{b.last_pos}"
    current_player = b.display.next_turn
  end

  winner = b.winner
  puts winner ? "player '#{Board::PLAYERS[winner]}' wins." : 'Tie Game.'
  puts 'Game Over.'
end

def game
  puts 'Starting tic-tac-toe...'
  first_player = rand(2)
  first_player = -1 if first_player == 0

  loop do
    one_play(first_player)
    puts 'Play again? y/n'
    exit if gets.downcase.strip != 'y'
  end
end

game

