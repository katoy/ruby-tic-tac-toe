# -*- coding: utf-8 -*-
require 'benchmark'

module T3Config
  BOARD_MAX_INDEX = 2
  BOARD_DIM = BOARD_MAX_INDEX + 1
  BOARD_LEN = BOARD_DIM * BOARD_DIM
  PLAYERS = { -1 => 'X', 1 => 'O', 0 => ' ' }
  COMPUTER_PLAYER = -1
  HUMAN_PLAYER = 1
  EMPTY_POS = 0

  def self.t3_corners
    [[0, 0], [0, BOARD_MAX_INDEX], [BOARD_MAX_INDEX, 0], [BOARD_MAX_INDEX, BOARD_MAX_INDEX]].freeze
  end

  def self.t3_centers
    crow, ccol = [BOARD_MAX_INDEX / 2, BOARD_MAX_INDEX / 2]
    centers = [[crow, ccol]]
    centers += [[crow + 1, ccol], [crow, ccol + 1], [crow + 1, ccol + 1]] if BOARD_MAX_INDEX.odd?
    centers.freeze
  end

  def self.t3_lines
    ans = []
    (0 .. BOARD_MAX_INDEX).each do |x|
      v_line, h_line = [[], []]
      (0 .. BOARD_MAX_INDEX).each do |y|
        v_line << [y, -1]
        h_line << [-1, y]
      end
      (0 .. BOARD_MAX_INDEX).each { |y| v_line[y][1], h_line[y][0] = [x, x] }
      ans += [v_line, h_line]
    end
    d1, d2 = [[], []]
    (0 .. BOARD_MAX_INDEX).each do |x|
      d1 << [x, x]
      d2 << [x, BOARD_MAX_INDEX - x]
    end
    ans += [d1, d2]
    ans.freeze
  end

  CORNERS = T3Config.t3_corners
  CENTERS = T3Config.t3_centers
  LINES = T3Config.t3_lines

  def tos
    @board.flatten + [@current_player]
  end

  def display
    bar_len = 4 * BOARD_DIM - 1
    bar_len = 6 * BOARD_DIM - 1 if BOARD_MAX_INDEX > 2
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
    label = (row * BOARD_DIM + col + 1).to_s if val == EMPTY_POS
    label = format('%3s', label) if BOARD_MAX_INDEX > 2
    label
  end

  def pos_to_rc(pos)
    [(pos - 1) / BOARD_DIM, (pos - 1) % BOARD_DIM]
  end

  def rc_to_pos(row, col)
    row * BOARD_DIM + col + 1
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
    read_pos(pos) == EMPTY_POS
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
    @history << [rc_to_pos(row, col), player]
    self
  end

  def validate_position_for_write(row, col)
    return true if validate_position(row, col) && empty?(row, col)
    puts 'That position is occupie.' if @current_player != COMPUTER_PLAYER
    false
  end

  def validate_position(row, col)
    return true if row <= BOARD_DIM && col <= BOARD_DIM
    puts 'Invalid position.' if @current_player != COMPUTER_PLAYER
    false
  end

  def full?
    (1 .. BOARD_LEN).each do |pos|
      return false if empty_pos?(pos)
    end
    true
  end

  def winner
    LINES.each do |line|
      score = 0
      (0 .. BOARD_MAX_INDEX).each { |idx| score += @board[line[idx][0]][line[idx][1]] }
      return @board[line[0][0]][line[0][1]] if score.abs == BOARD_DIM
    end
    nil
  end

  def emps
    ans = []
    (1 .. BOARD_LEN).each { |pos| ans << pos if empty_pos?(pos) }
    ans.map { |pos| pos_to_rc(pos) }
  end

  def can_writes(pos_set)
    ans = []
    pos_set.each { |cs| ans << cs if empty?(cs[0], cs[1]) }
    ans
  end

  def next_turn
    @current_player = (-1) * @current_player
  end
end

class Stage
  include T3Config

  attr_reader :current_player, :pos, :depth, :score, :childs

  def initialize(current_player, pos, board, depth)
    @current_player = current_player
    @pos = pos
    @depth = depth
    @childs = []
    @board = board
    @score = nil
  end

  def generate_childs
    w = winner
    if w
      @score = (-1) * w * (100 - @depth)
      return self
    end
    if @depth == BOARD_LEN
      @score = 0
      return self
    end

    child_scores = []
    emps.each do |p|
      row, col = p
      pos = rc_to_pos(row, col)
      board = Marshal.load(Marshal.dump(@board))
      board[row][col] = current_player
      ch = Stage.new(current_player * (-1), pos, board, @depth + 1).generate_childs
      child_scores << ch.score
      @childs << ch
    end
    if current_player == HUMAN_PLAYER
      @score = child_scores.min
    else
      @score = child_scores.max
    end
    self
  end

  def to_s
    x = {}
    childs.each { |m| x[m.pos] = m.score }
    x.to_s
  end
end

class Board
  include T3Config

  @@calced_stages = nil
  attr_reader :current_player, :centers, :corners, :lines, :stages

  def initialize(current_player)
    @current_player = current_player  # 1 or -1
    @history = []                     # Array of [pos, player], ...
    @board = []                       # board[row][col] = 1 or -1 or 0
    (0 .. BOARD_MAX_INDEX).each { |x| @board << [EMPTY_POS] * BOARD_DIM }
    if @@calced_stages
      @stages = @@calced_stages
    else
      puts '#-- analysing game ...'
      puts  Benchmark.measure {
        @stages = Stage.new(current_player, nil, Marshal.load(Marshal.dump(@board)), 0).generate_childs.freeze
      }
      @@calced_stages = @stages
    end
  end

  def last_pos
    return '' if @history.size == 0
    @history[-1][0]
  end

  def last_rc
    pos_to_rc(last_pos)
  end

  # rotate matrix 90 deg.
  # def rotate_left
  #  @board.transpose.reverse
  # end

  def ask_player_for_move(current_player, stdin = STDIN)
    (current_player == COMPUTER_PLAYER) ? computer_move(current_player) : human_move(current_player, stdin)
    self
  end

  def human_move(current_player, stdin = STDIN)
    loop do
      begin
        puts "Player #{PLAYERS[current_player]}: Where would you like to play?"
        pos = stdin.gets.to_i
        update_stages pos
        return write_pos(pos, current_player) if 0 < pos && pos <= BOARD_LEN
      rescue => e
        puts e
      end
    end
  end

  def update_stages(pos)
    @stages.childs.each do |c|
      if c.pos == pos
        @stages = c
        return
      end
    end
  end

  def computer_move(current_player)
    moves = @stages.childs
    move = nil
    if current_player == COMPUTER_PLAYER
      move = moves.max { |a, b| a.score <=> b.score }
    else
      move = moves.min { |a, b| a.score <=> b.score }
    end
    @stages = move
    write_pos(move.pos, current_player)
  end
end
