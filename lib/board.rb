# -*- coding: utf-8 -*-

class Board
  BOARD_MAX_INDEX = 2
  PLAYERS = { -1 => 'X', 1 => 'O', 0 => ' ' }
  COMPUTER_PLAYER = -1
  HUMAN_PLAYER = 1
  EMPTY_POS = 0

  attr_reader :current_player, :centers, :corners, :lines

  def initialize(current_player)
    @current_player = current_player
    @history = []
    @board = []
    (0 .. BOARD_MAX_INDEX).each { |x| @board << [EMPTY_POS] * (BOARD_MAX_INDEX + 1) }

    @corners = [[0, 0], [0, BOARD_MAX_INDEX], [BOARD_MAX_INDEX, 0], [BOARD_MAX_INDEX, BOARD_MAX_INDEX]].freeze
    crow, ccol = [BOARD_MAX_INDEX / 2, BOARD_MAX_INDEX / 2]

    @centers = [[crow, ccol]]
    @corners += [[crow + 1, ccol], [crow, ccol + 1], [crow + 1, ccol + 1]] if BOARD_MAX_INDEX.odd?
    @centers.freeze

    @lines = []
    (0 .. BOARD_MAX_INDEX).each do |x|
      v_line, h_line = [[], []]
      (0 .. BOARD_MAX_INDEX).each do |y|
        v_line << [y, -1]
        h_line << [-1, y]
      end
      (0 .. BOARD_MAX_INDEX).each { |z| v_line[z][1], h_line[z][0] = [x, x] }
      @lines += [v_line, h_line]
    end
    d1, d2 = [[], []]
    (0 .. BOARD_MAX_INDEX).each do |x|
      d1 << [x, x]
      d2 << [x, BOARD_MAX_INDEX - x]
    end
    @lines += [d1, d2]
    @lines.freeze
  end

  def last_pos
    return '' if @history.size == 0
    row, col, _player = @history[-1]
    rc_to_pos(row, col)
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
    throw "--- invalid position, #{rc_to_pos(row, col)} [#{row}, #{col}]" unless validate_position(row, col)
    @board[row][col]
  end

  def empty_pos?(pos)
    row, col = pos_to_rc(pos)
    empty?(row, col)
  end

  def empty?(row, col)
    read_rc(row, col) == EMPTY_POS
  end

  def write_pos(pos, player)
    row, col = pos_to_rc(pos)
    write_rc(row, col, player)
  end

  def write_rc(row, col, player)
    throw "--- not empty #{rc_to_pos(row, col)} [#{row}, #{col}]" unless validate_position_for_write(row, col)
    @board[row][col] = player
    @history << [row, col, player]
    self
  end

  def go_rc(row, col, player)
    @board[row][col] = player
  end

  def back_rc(row, col)
    @board[row][col] = EMPTY_POS
    self
  end

  def validate_position_for_write(row, col)
    return true if validate_position(row, col) && empty?(row, col)
    puts 'That position is occupie.' if @current_player != COMPUTER_PLAYER
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
      (0 .. BOARD_MAX_INDEX).each { |col| print "#{get_label(row, col, read_rc(row, col))} | " }
      puts "\n+#{'-' * bar_len}+ "
    end
    self
  end

  def get_label(row, col, val)
    label = PLAYERS[val]
    label = (row * (BOARD_MAX_INDEX + 1) + col + 1).to_s if val == EMPTY_POS
    label = format('%3s', label) if BOARD_MAX_INDEX > 2
    label
  end

  def full?
    (1 .. (BOARD_MAX_INDEX + 1) * (BOARD_MAX_INDEX + 1)).each do |pos|
      return false if empty_pos?(pos)
    end
    true
  end

  def winner
    @lines.each do |line|
      score = 0
      (0 .. BOARD_MAX_INDEX).each { |idx| score += read_rc(line[idx][0], line[idx][1]) }
      return read_rc(line[0][0], line[0][1]) if score.abs == (BOARD_MAX_INDEX + 1)
    end
    nil  # no winner
  end

  def ask_player_for_move(current_player, stdin = STDIN)
    (current_player == COMPUTER_PLAYER) ? computer_move(current_player) : human_move(current_player, stdin)
    self
  end

  def human_move(current_player, stdin = STDIN)
    loop do
      begin
        puts "Player #{PLAYERS[current_player]}: Where would you like to play?"
        pos = stdin.gets.to_i
        return write_pos(pos, current_player) if 0 < pos && pos <= (BOARD_MAX_INDEX + 1) * (BOARD_MAX_INDEX + 1)
      rescue => e
        puts e
      end
    end
  end

  def computer_move(current_player)
    moves = check_win(current_player) + check_win(-1 * current_player) +
      can_writes(@centers).shuffle + can_writes(@corners).shuffle + emps.shuffle
    if moves.size > 0
      row, col = moves[0]
      write_rc(row, col, current_player)
    end
  end

  def check_win(player)
    ans = []
    (1 .. (BOARD_MAX_INDEX + 1) * (BOARD_MAX_INDEX + 1)).each do |pos|
      row, col = pos_to_rc(pos)
      if empty?(row, col)
        go_rc(row, col, player)
        ans << [row, col] if winner == player
        back_rc(row, col)
      end
    end
    ans
  end

  def can_writes(pos_set)
    ans = []
    pos_set.each { |cs| ans << cs if empty?(cs[0], cs[1]) }
    ans
  end

  def emps
    ans = []
    (1 .. (BOARD_MAX_INDEX + 1) * (BOARD_MAX_INDEX + 1)).each { |pos| ans << pos if empty_pos?(pos) }
    ans.map { |pos| pos_to_rc(pos) }
  end

  def next_turn
    @current_player = (-1) * @current_player
  end
end
