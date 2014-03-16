# -*- coding: utf-8 -*-

class Board
  BOARD_MAX_INDEX = 2
  PLAYERS = { -1 => 'X', 1 => 'O', 0 => ' ' }
  COMPUTER_PLAYER = -1
  HUMAN_PLAYER = 1
  EMPTY_POS = 0

  attr_reader :current_player

  def initialize(current_player)
    @current_player = current_player
    @board = []
    (0 .. BOARD_MAX_INDEX).each do |x|
      @board << [EMPTY_POS] * (BOARD_MAX_INDEX + 1)
    end
    @history = []
  end

  def last_pos
    ans = ''
    if @history.size > 0
      row, col = @history[-1]
      ans = rc_to_pos(row, col)
    end
    ans
  end

  def last_rc
    pos_to_rc(last_pos)
  end

  # rotate matrix 90 deg.
  # def rotate_left
  #  @board.transpose.reverse
  # end

  def tos
    @board.flatten + [@current_player]
  end

  def pos_to_rc(pos)
    [(pos - 1) / (BOARD_MAX_INDEX + 1), (pos - 1) % (BOARD_MAX_INDEX + 1)]
  end

  def rc_to_pos(row, col)
    row * (BOARD_MAX_INDEX + 1) + col + 1
  end

  def read_pos(pos)
    row, col = pos_to_rc(pos)
    read_rc(row, col)
  end

  def read_rc(row, col)
    throw "--- not empty #{row}, #{col}" unless validate_position(row, col)
    @board[row][col]
  end

  def empty?(row, col)
    read_rc(row, col) == EMPTY_POS
  end

  def write_pos(pos, player)
    row, col = pos_to_rc(pos)
    write_rc(row, col, player)
  end

  def write_rc(row, col, player)
    throw "--- not empty #{row}, #{col}" unless validate_position_for_write(row, col)
    @board[row][col] = player
    @history << [row, col]
  end

  def go_rc(row, col, player)
    @board[row][col] = player
  end

  def back_rc(row, col)
    @board[row][col] = EMPTY_POS
  end

  def validate_position_for_write(row, col)
    return true if validate_position(row, col) && empty?(row, col)
    puts 'That positon is occupie.' if @current_player != COMPUTER_PLAYER
    false
  end

  def validate_position(row, col)
    return true if row <= (BOARD_MAX_INDEX + 1) && col <= (BOARD_MAX_INDEX + 1)
    puts 'Invalid position.' if @current_player != COMPUTER_PLAYER
    false
  end

  def display
    bar_len = (4 * (BOARD_MAX_INDEX + 1)) - 1
    bar_len = (6 * (BOARD_MAX_INDEX + 1)) - 1 if BOARD_MAX_INDEX > 2
    puts "+#{'-' * bar_len}+ "
    (0 .. BOARD_MAX_INDEX).each do |row|
      print '| '
      (0 .. BOARD_MAX_INDEX).each do |col|
        print "#{get_label(row, col, read_rc(row, col))} | "
      end
      puts "\n+#{'-' * bar_len}+ "
    end
  end

  def get_label(row, col, val)
    label = PLAYERS[val]
    label = (row * (BOARD_MAX_INDEX + 1) + col + 1).to_s if val == EMPTY_POS
    label = sprintf('%3s', label) if BOARD_MAX_INDEX > 2
    label
  end

  def full?
    (0 .. BOARD_MAX_INDEX).each do |row|
      (0 .. BOARD_MAX_INDEX).each do |col|
        return false if empty?(row, col)
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
      sum = 0
      (0 .. BOARD_MAX_INDEX).each do |col_idx|
        sum += read_rc(row_idx, col_idx)
      end
      return read_rc(row_idx, 0) if sum.abs == (BOARD_MAX_INDEX + 1)
    end
    nil
  end

  def winner_cols
    (0 .. BOARD_MAX_INDEX).each do |col_idx|
      sum = 0
      (0 .. BOARD_MAX_INDEX).each do |row_idx|
        sum += read_rc(row_idx, col_idx)
      end
      return read_rc(0, col_idx) if sum.abs == (BOARD_MAX_INDEX + 1)
    end
    nil
  end

  def winner_diagonals_1
    sum = 0
    (0 .. BOARD_MAX_INDEX).each do |idx|
      sum += read_rc(idx, idx)
    end
    return read_rc(0, 0) if sum.abs == (BOARD_MAX_INDEX + 1)
    nil
  end

  def winner_diagonals_2
    sum = 0
    (0 .. BOARD_MAX_INDEX).each do |idx|
      sum += read_rc(idx, BOARD_MAX_INDEX - idx)
    end
    return read_rc(0, BOARD_MAX_INDEX) if sum.abs == (BOARD_MAX_INDEX + 1)
    nil
  end

  def ask_player_for_move(current_player, stdin = STDIN)
    if current_player == COMPUTER_PLAYER
      computer_move(current_player)
    else
      human_move(current_player, stdin)
    end
  end

  def human_move(current_player, stdin = STDIN)
    loop do
      begin
        puts "Player #{PLAYERS[current_player]}: Where would you like to play?"
        s = stdin.gets
        pos = s.to_i
        if 0 < pos && pos <= (BOARD_MAX_INDEX + 1) * (BOARD_MAX_INDEX + 1)
          write_pos(pos, current_player)
          return
        end
      rescue => e
        puts e
      end
    end
  end

  def computer_move(current_player)
    win = check_win(current_player)
    lose = check_win(-1 * current_player)
    ava = available_rc

    row, col = [-1, -1]
    if win.size > 0
      row, col = win[0]
    elsif lose.size > 0
      row, col = lose[0]
    elsif ava.size > 0
      row, col = ava[0]
    end
    write_rc(row, col, current_player) if row > -1
  end

  def check_win(player)
    ans = []
    (0 .. BOARD_MAX_INDEX).each do |row|
      (0 .. BOARD_MAX_INDEX).each do |col|
        if empty?(row, col)
          go_rc(row, col, player)
          ans << [row, col] if winner == player
          back_rc(row, col)
        end
      end
    end
    ans
  end

  def available_rc
    # Centers, Corners, Empties
    cent = centers
    corns = corners
    centers.shuffle + corns.shuffle + (emps - cent - corns).shuffle
  end

  def centers
    ans = []
    crow, ccol = [BOARD_MAX_INDEX / 2, BOARD_MAX_INDEX / 2]
    ans << [crow, ccol] if empty?(crow, ccol)
    if BOARD_MAX_INDEX.odd?
      ans << [crow + 1, ccol] if empty?(crow + 1, ccol)
      ans << [crow, ccol + 1] if empty?(crow, ccol + 1)
      ans << [crow + 1, ccol + 1] if empty?(crow + 1, ccol + 1)
    end
    ans
  end

  def corners
    ans = []
    ans << [0, 0] if empty?(0, 0)
    ans << [0, BOARD_MAX_INDEX] if empty?(0, BOARD_MAX_INDEX)
    ans << [BOARD_MAX_INDEX, 0] if empty?(BOARD_MAX_INDEX, 0)
    ans << [BOARD_MAX_INDEX, BOARD_MAX_INDEX] if empty?(BOARD_MAX_INDEX, BOARD_MAX_INDEX)
    ans
  end

  def emps
    ans = []
    (0 .. BOARD_MAX_INDEX).each do |row|
      (0 .. BOARD_MAX_INDEX).each do |col|
        ans << [row, col] if empty?(row, col)
      end
    end
    ans
  end

  def next_turn
    @current_player = (-1) * @current_player
  end
end
