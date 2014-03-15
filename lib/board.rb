# -*- coding: utf-8 -*-

class Board
  BOARD_MAX_INDEX = 2
  EMPTY_POS = '.'
  PLAYERS = %w(X O)
  COMPUTER_PLAYER = PLAYERS[0]
  HUMAN_PLAYER = PLAYERS[1]

  attr_reader :board, :current_player

  def initialize(current_player)
    @current_player = current_player
    @board = Array.new(BOARD_MAX_INDEX + 1) do
      Array.new(BOARD_MAX_INDEX + 1) do
        EMPTY_POS
      end
    end
  end

  def tos
    ans = []
    @board.each do |row|
      row.each do |cel|
        ans << cel
      end
    end
    ans << @current_player
    ans
  end

  def display
    bar_len = (4 * (BOARD_MAX_INDEX + 1)) - 1
    bar_len = (6 * (BOARD_MAX_INDEX + 1)) - 1 if BOARD_MAX_INDEX > 2
    puts "+#{'-' * bar_len}+"
    (0 .. BOARD_MAX_INDEX).each do |row|
      print '| '
      (0 .. BOARD_MAX_INDEX).each do |col|
        print "#{get_label(row, col, @board[row][col])} | "
      end
      puts "\n+#{'-' * bar_len}+"
    end
  end

  def get_label(row, col, val)
    label = val
    label = (row * (BOARD_MAX_INDEX + 1) + col + 1).to_s if val == EMPTY_POS
    label = sprintf('%3s', label) if BOARD_MAX_INDEX > 2
    label
  end

  def full?
    (0 .. BOARD_MAX_INDEX).each do |row|
      (0 .. BOARD_MAX_INDEX).each do |col|
        return false if @board[row][col] == EMPTY_POS
      end
    end
    true
  end

  def winner
    winner = winner_rows
    return winner if winner
    winner = winner_cols
    return winner if winner
    winner = winner_diagonals_1
    return winner if winner
    winner = winner_diagonals_2
    return winner if winner
    # No winners
    nil
  end

  def winner_rows
    (0 .. BOARD_MAX_INDEX).each do |row_idx|
      winner = @board[row_idx][0]
      next if winner == EMPTY_POS
      (1 .. BOARD_MAX_INDEX).each do |col_idx|
        winner = nil if winner != @board[row_idx][col_idx]
      end
      return winner if winner
    end
    nil
  end

  def winner_cols
    (0 .. BOARD_MAX_INDEX).each do |col_idx|
      winner = @board[0][col_idx]
      next if winner == EMPTY_POS
      (1 .. BOARD_MAX_INDEX).each do |row_idx|
        winner = nil if winner != @board[row_idx][col_idx]
      end
      return winner if winner
    end
    nil
  end

  def winner_diagonals_1
    winner = @board[0][0]
    return nil if winner == EMPTY_POS
    (1 .. BOARD_MAX_INDEX).each do |idx|
      winner = nil if winner != @board[idx][idx]
    end
    winner
  end

  def winner_diagonals_2
    winner = @board[0][BOARD_MAX_INDEX]
    return nil if winner == EMPTY_POS
    (1 .. BOARD_MAX_INDEX).each do |idx|
      winner = nil if winner != @board[idx][BOARD_MAX_INDEX - idx]
    end
    winner
  end

  def ask_player_for_move(current_player)
    if current_player == COMPUTER_PLAYER
      computer_move(current_player)
    else
      human_move(current_player)
    end
  end

  def human_move(current_player)
    played = false
    until played
      puts 'Player #{current_player}: Where would you like to play?'
      move = gets.to_i - 1
      row, col = [move / @board.size, move % @board.size]
      if validate_position(row, col)
        @board[row][col] = current_player
        played = true
      end
    end
  end

  def computer_move(current_player)
    row, col = [-1, -1]
    found = 'F'

    # check_rows(COMPUTER_PLAYER, found)
    # check_cols(COMPUTER_PLAYER, found)
    # check_diagonals(COMPUTER_PLAYER, found)

    # check_rows(HUMAN_PLAYER, found)
    # check_cols(HUMAN_PLAYER, found)
    # check_diagonals(HUMAN_PLAYER, found)

    if found == 'F'
      if @board[1][1] == EMPTY_POS
        @board[1][1] = current_player
      # elsif available_corner()
      #  pick_corner(current_player)
      else
        row, col = [rand(@board.size), rand(@board.size)]  until validate_position(row, col)
        @board[row][col] = current_player
      end
    end
  end

  def validate_position(row, col)
    if row <= @board.size && col <= @board.size
      return true if @board[row][col] == EMPTY_POS
      puts 'That positon is occupie.' if @current_player != COMPUTER_PLAYER
    else
      puts 'Invalid position.' if @current_player != COMPUTER_PLAYER
    end
    false
  end

  def next_turn
    @current_player = @current_player == 'X' ? 'O' : 'X'
  end
end
