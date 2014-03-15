class Board
  BOARD_MAX_INDEX = 5
  EMPTY_POS = '.'
  PLAYERS = ['X', 'O'].freeze
  COMPUTER_PLAYER = 'X'
  HUMAN_PLAYER = 'O'

  attr_reader :board, :current_player

  def self.players
    PLAYERS
  end

  def initialize(current_player)
    @current_player = current_player
    @board = Array.new(BOARD_MAX_INDEX + 1) {
      Array.new(BOARD_MAX_INDEX + 1) {
        EMPTY_POS
      }
    }
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
    for row in 0 .. BOARD_MAX_INDEX
      print '| '
      for col in 0 .. BOARD_MAX_INDEX
        print get_label(row, col, @board[row][col])
        print ' | '
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
    for row in 0 .. BOARD_MAX_INDEX
      for col in 0 .. BOARD_MAX_INDEX
        return false if @board[row][col] == EMPTY_POS
      end
    end
    true
  end

  def winner
    winner = winner_rows()
    return winner if winner
    winner = winner_cols()
    return winner if winner
    winner = winner_diagonals()
    return winner if winner
    # No winners
    nil
  end

  def winner_rows
    for row_index in 0 .. BOARD_MAX_INDEX
      first_symbol = @board[row_index][0]
      for col_index in 1 .. BOARD_MAX_INDEX
        if first_symbol != @board[row_index][col_index]
          break
        elsif col_index == BOARD_MAX_INDEX and first_symbol != EMPTY_POS
          return first_symbol
        end
      end
    end
    nil
  end

  def winner_cols
    for col_index in 0 .. BOARD_MAX_INDEX
      first_symbol = @board[0][col_index]
      for row_index in 1 .. BOARD_MAX_INDEX
        if first_symbol != @board[row_index][col_index]
          break
        elsif row_index == BOARD_MAX_INDEX and first_symbol != EMPTY_POS
          return first_symbol
        end
      end
    end
    nil
  end

  def winner_diagonals
    first_symbol = @board[0][0]
    for index in 1 .. BOARD_MAX_INDEX
      if first_symbol != @board[index][index]
        break
      elsif index == BOARD_MAX_INDEX and first_symbol != EMPTY_POS
        return first_symbol
      end
    end
    first_symbol = @board[0][BOARD_MAX_INDEX]
    row_index = 0
    col_index = BOARD_MAX_INDEX
    while row_index < BOARD_MAX_INDEX
      row_index = row_index + 1
      col_index = col_index - 1
      if first_symbol != @board[row_index][col_index]
        break
      elsif row_index == BOARD_MAX_INDEX and first_symbol != EMPTY_POS
        return first_symbol
      end
    end
    nil
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
    while not played
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

    #check_rows(COMPUTER_PLAYER, found)
    #check_cols(COMPUTER_PLAYER, found)
    #check_diagonals(COMPUTER_PLAYER, found)

    #check_rows(HUMAN_PLAYER, found)
    #check_cols(HUMAN_PLAYER, found)
    #check_diagonals(HUMAN_PLAYER, found)

    if found == 'F'
      if @board[1][1] == EMPTY_POS
        row, col = [1, 1]
        @board[row][col] = current_player
      #elsif available_corner()
      #  pick_corner(current_player)
      else
        until validate_position(row, col)
          row, col = [rand(@board.size), rand(@board.size)]
        end
        @board[row][col] = current_player
      end
    end
  end

  def validate_position(row, col)
    if row <= @board.size and col <= @board.size
      return true if @board[row][col] == EMPTY_POS
      puts 'That positon is occupie.'
    else
      puts 'Invalid position.'
    end
    false
  end

  def get_next_turn
    @current_player = @current_player == 'X' ? 'O' : 'X'
  end

end
