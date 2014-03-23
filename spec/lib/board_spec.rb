# -*- coding: utf-8 -*-

require 'spec_helper'
require 'board.rb'
require 'pp'

describe Board do
  context 'PLAYER' do
    it 'should PLAYER +1, -1' do
      expect(Board::PLAYERS[-1]).to eq('X')
      expect(Board::PLAYERS[1]).to eq('O')
      expect(Board::PLAYERS[0]).to eq(' ')
    end
  end

  context '#new' do
    it 'should initialize a new board' do
      b = Board.new(1)
      expect(b.current_player).to eq(+1)
      expect(b.tos).to eq([0, 0, 0,
                           0, 0, 0,
                           0, 0, 0, 1])
      expect(T3Config::CENTERS).to eq([[1,1]])
      expect(T3Config::CORNERS).to eq([[0, 0], [0, 2], [2, 0], [2, 2]])
      expect(T3Config::LINES).to eq( [
                              [[0, 0], [1, 0], [2, 0]],
                              [[0, 0], [0, 1], [0, 2]],
                              [[0, 1], [1, 1], [2, 1]],
                              [[1, 0], [1, 1], [1, 2]],
                              [[0, 2], [1, 2], [2, 2]],
                              [[2, 0], [2, 1], [2, 2]],
                              [[0, 0], [1, 1], [2, 2]],
                              [[0, 2], [1, 1], [2, 0]]
                             ])
    end
  end

  context '#emps' do
    it 'emps' do
      b = Board.new(1)
      expect(b.emps).to eq([[0, 0], [0, 1], [0, 2], [1, 0], [1, 1], [1, 2], [2, 0], [2, 1], [2, 2]])
      b.write_rc(1, 1, 1).write_rc(0, 0, -1).write_rc(0, 2, 1).write_rc(2, 0, 1).write_rc(2, 2, -1)
      expect(b.emps).to eq([[0, 1], [1, 0], [1, 2], [2, 1]])
    end
  end

  context '#write_pos' do
    it 'move valid' do
      b = Board.new(1)
      (1 .. 9).each do |p|
        b.write_pos(p, -1)
      end
      expect(b.tos).to eq([-1, -1, -1,
                           -1, -1, -1,
                           -1, -1, -1, 1])
    end
  end

  context '#write_rc' do
    it 'move valid' do
      b = Board.new(1)
      (0 .. 2).each do |r|
        (0 .. 2).each do |c|
          b.write_rc(r, c, -1)
        end
      end
      expect(b.tos).to eq([-1, -1, -1,
                           -1, -1, -1,
                           -1, -1, -1, 1])
    end
  end

  context '#write_rc' do
    it 'move valid' do
      b = Board.new(-1)
      (0 .. 0).each do |r|
        (0 .. 2).each do |c|
          b.write_rc(r, c, 1)
        end
      end
      expect(b.tos).to eq([1, 1, 1,
                           0, 0, 0,
                           0, 0, 0, -1])
    end
  end

  context '#full?' do
    it 'move valid' do
      b = Board.new(-1)
      expect(b.full?).to eq(false)
      (0 .. 2).each do |r|
        (0 .. 2).each do |c|
          expect(b.full?).to eq(false)
          b.write_rc(r, c, b.next_turn)
        end
      end
      expect(b.full?).to eq(true)
    end

  end

  context '#winner' do
    it 'row' do
      b = Board.new(-1)
      expect(b.winner).to eq(nil)
      b.write_rc(0, 0, 1)
      expect(b.winner).to eq(nil)
      b.write_rc(0, 1, 1)
      expect(b.winner).to eq(nil)
      b.write_rc(0, 2, 1)
      expect(b.winner).to eq(1)
    end
    it 'col' do
      b = Board.new(-1)
      expect(b.winner).to eq(nil)
      b.write_rc(0, 0, 1)
      expect(b.winner).to eq(nil)
      b.write_rc(1, 0, 1)
      expect(b.winner).to eq(nil)
      b.write_rc(2, 0, 1)
      expect(b.winner).to eq(1)
    end
    it 'diag' do
      b = Board.new(-1)
      expect(b.winner).to eq(nil)
      b.write_rc(0, 0, 1)
      expect(b.winner).to eq(nil)
      b.write_rc(1, 1, 1)
      expect(b.winner).to eq(nil)
      b.write_rc(2, 2, 1)
      expect(b.winner).to eq(1)
    end
    it 'diag_2' do
      b = Board.new(-1)
      expect(b.winner).to eq(nil)
      b.write_rc(2, 0, 1)
      expect(b.winner).to eq(nil)
      b.write_rc(1, 1, 1)
      expect(b.winner).to eq(nil)
      b.write_rc(0, 2, 1)
      expect(b.winner).to eq(1)
    end
  end

  context '#computer_move' do
    it 'center' do
      b = Board.new(-1)
      b.computer_move(-1)
      expect(b.read_rc(0, 0)).to eq(-1)
      expect(b.rc_to_pos(0, 0)).to eq(1)
      expect(b.read_pos(1)).to eq(-1)

      expect { b.write_rc(0, 0, -1) }.to raise_error(ArgumentError)
      expect { b.write_rc(4, 1, -1) }.to raise_error(ArgumentError)
    end

    it 'should move defence diag' do
      b = Board.new(1)
      b.write_rc(0, 0, 1)
      b.update_stages(1)
      b.write_rc(0, 1, -1)
      b.update_stages(2)
      b.write_rc(1, 1, 1)
      b.update_stages(5)
      b.computer_move(-1)
      expect(b.last_rc).to eq([2, 2])

      b = Board.new(1)
      b.write_rc(0, 2, 1)
      b.update_stages(3)
      b.write_rc(0, 1, -1)
      b.update_stages(2)
      b.write_rc(1, 1, 1)
      b.update_stages(5)
      b.computer_move(-1)
      expect(b.last_rc).to eq([2, 0])
    end

    it 'should move defence row' do
      b = Board.new(1)
      b.write_rc(0, 0, 1)
      b.update_stages(1)
      b.write_rc(1, 1, -1)
      b.update_stages(5)
      b.write_rc(0, 1, 1)
      b.update_stages(2)
      b.computer_move(-1)
      expect(b.last_rc).to eq([0, 2])

      b = Board.new(-1)
      b.write_rc(1, 0, 1)
      b.update_stages(4)
      b.write_rc(0, 0, -1)
      b.update_stages(1)
      b.write_rc(1, 1, 1)
      b.update_stages(5)
      b.computer_move(-1)
      expect(b.last_rc).to eq([1, 2])

      b = Board.new(1)
      b.write_rc(2, 0, 1)
      b.update_stages(7)
      b.write_rc(1, 1, -1)
      b.update_stages(5)
      b.write_rc(2, 1, 1)
      b.update_stages(8)
      b.computer_move(-1)
      expect(b.last_rc).to eq([2, 2])
    end

    it 'should move defence col' do
      b = Board.new(1)
      b.write_rc(0, 0, 1)
      b.update_stages(1)
      b.write_rc(1, 1, -1)
      b.update_stages(5)
      b.write_rc(1, 0, 1)
      b.update_stages(4)
      b.computer_move(-1)
      expect(b.last_rc).to eq([2, 0])

      b = Board.new(1)
      b.write_rc(0, 1, 1)
      b.update_stages(2)
      b.write_rc(0, 0, -1)
      b.update_stages(1)
      b.write_rc(1, 1, 1)
      b.update_stages(5)
      b.computer_move(-1)
      expect(b.last_rc).to eq([2, 1])

      b = Board.new(1)
      b.write_rc(0, 2, 1)
      b.update_stages(3)
      b.write_rc(0, 1, -1)
      b.update_stages(2)
      b.write_rc(1, 2, 1)
      b.update_stages(6)
      b.computer_move(-1)
      expect(b.last_rc).to eq([2, 2])
    end

    it 'should move win diag' do
      b = Board.new(1)
      b.write_rc(0, 0, 1)
      b.update_stages(1)
      b.write_rc(0, 1, -1)
      b.update_stages(2)
      b.write_rc(1, 1, 1)
      b.update_stages(5)
      b.computer_move(-1)
      expect(b.last_rc).to eq([2, 2])

      b = Board.new(1)
      b.write_rc(0, 2, -1)
      b.update_stages(3)
      b.write_rc(0, 1, 1)
      b.update_stages(2)
      b.write_rc(1, 1, -1)
      b.update_stages(5)
      b.computer_move(-1)
      expect(b.last_rc).to eq([2, 0])
    end

    it 'should move win row' do
      b = Board.new(1)
      b.write_rc(0, 0, 1)
      b.update_stages(1)
      b.write_rc(1, 1, -1)
      b.update_stages(5)
      b.write_rc(0, 1, 1)
      b.update_stages(2)
      b.computer_move(-1)
      expect(b.last_rc).to eq([0, 2])

      b = Board.new(1)
      b.write_rc(1, 0, 1)
      b.update_stages(4)
      b.write_rc(0, 0, -1)
      b.update_stages(1)
      b.write_rc(1, 1, 1)
      b.update_stages(5)
      b.computer_move(-1)
      expect(b.last_rc).to eq([1, 2])

      b = Board.new(1)
      b.write_rc(2, 0, 1)
      b.update_stages(7)
      b.write_rc(1, 1, -1)
      b.update_stages(5)
      b.write_rc(2, 1, 1)
      b.update_stages(8)
      b.computer_move(-1)
      expect(b.last_rc).to eq([2, 2])
    end

    it 'should move win col' do
      b = Board.new(1)
      b.write_rc(0, 0, 1)
      b.update_stages(1)
      b.write_rc(1, 1, -1)
      b.update_stages(5)
      b.write_rc(1, 0, 1)
      b.update_stages(4)
      b.computer_move(-1)
      expect(b.last_rc).to eq([2, 0])

      b = Board.new(1)
      b.write_rc(0, 1, 1)
      b.update_stages(2)
      b.write_rc(0, 0, -1)
      b.update_stages(1)
      b.write_rc(1, 1, 1)
      b.update_stages(5)
      b.computer_move(-1)
      expect(b.last_rc).to eq([2, 1])

      b = Board.new(1)
      b.write_rc(0, 2, 1)
      b.update_stages(3)
      b.write_rc(0, 0, -1)
      b.update_stages(1)
      b.write_rc(1, 2, 1)
      b.update_stages(6)
      b.computer_move(-1)
      expect(b.last_rc).to eq([2, 2])
    end

  end

  context '#next_turn' do
    it 'move valid' do
      b = Board.new(-1)
      next_turn = b.next_turn
      expect(next_turn).to eq(1)
      next_turn = b.next_turn
      expect(next_turn).to eq(-1)
      next_turn = b.next_turn
      expect(next_turn).to eq(1)
    end
  end

  context '#display' do
    it 'stdout' do
      b = Board.new(-1)
      b.write_rc(1, 1, 1)
      b.write_rc(2, 2, -1)
      expect(b.last_pos).to eq(9)

      output = capture(:stdout) { b.display }
      expect(output).to eq("+-----------+ \n" +
                           "| 1 | 2 | 3 | \n" +
                           "+-----------+ \n" +
                           "| 4 | O | 6 | \n" +
                           "+-----------+ \n" +
                           "| 7 | 8 | X | \n" +
                           "+-----------+ \n")
    end

    context 'ask_player_for_move' do
      it '3, 5, 1, 6, 9' do
        b = Board.new(1)

        stdin = double('stdin')
        stdin.stub(:gets) { '3' }
        b.ask_player_for_move(1, stdin)
        output = capture(:stdout) { b.display }
        expect(output).to eq("+-----------+ \n" +
                             "| 1 | 2 | O | \n" +
                             "+-----------+ \n" +
                             "| 4 | 5 | 6 | \n" +
                             "+-----------+ \n" +
                             "| 7 | 8 | 9 | \n" +
                             "+-----------+ \n")
        expect(b.winner).to eq(nil)

        b.ask_player_for_move(-1, stdin)
        output = capture(:stdout) { b.display }
        expect(output).to eq("+-----------+ \n" +
                             "| 1 | 2 | O | \n" +
                             "+-----------+ \n" +
                             "| 4 | X | 6 | \n" +
                             "+-----------+ \n" +
                             "| 7 | 8 | 9 | \n" +
                             "+-----------+ \n")
        expect(b.winner).to eq(nil)

        stdin.stub(:gets) { '1' }
        b.ask_player_for_move(1, stdin)
        output = capture(:stdout) { b.display }
        expect(output).to eq("+-----------+ \n" +
                             "| O | 2 | O | \n" +
                             "+-----------+ \n" +
                             "| 4 | X | 6 | \n" +
                             "+-----------+ \n" +
                             "| 7 | 8 | 9 | \n" +
                             "+-----------+ \n")
        expect(b.winner).to eq(nil)

        b.write_rc(1, 2, -1) # pos 6
        output = capture(:stdout) { b.display }
        expect(output).to eq("+-----------+ \n" +
                             "| O | 2 | O | \n" +
                             "+-----------+ \n" +
                             "| 4 | X | X | \n" +
                             "+-----------+ \n" +
                             "| 7 | 8 | 9 | \n" +
                             "+-----------+ \n")
        expect(b.winner).to eq(nil)

        stdin.stub(:gets) { '2' }
        b.ask_player_for_move(1, stdin)
        output = capture(:stdout) { b.display }
        expect(output).to eq("+-----------+ \n" +
                             "| O | O | O | \n" +
                             "+-----------+ \n" +
                             "| 4 | X | X | \n" +
                             "+-----------+ \n" +
                             "| 7 | 8 | 9 | \n" +
                             "+-----------+ \n")
        expect(b.winner).to eq(1)
      end
    end
  end

  context 'Lose patterm' do
    it 'shoud not lose special pattern 1' do
      b = Board.new(1)
      b.write_pos(1, 1)
      b.update_stages(1)
      b.write_pos(5, -1)
      b.update_stages(5)
      b.write_pos(9, 1)
      b.update_stages(9)
      b.computer_move(-1)
      expect(b.read_pos(3)).to eq(0)
      expect(b.read_pos(7)).to eq(0)
    end

    it 'shoud not lose special pattern 1' do
      b = Board.new(1)
      b.write_pos(3, 1)
      b.update_stages(3)
      b.write_pos(5, -1)
      b.update_stages(5)
      b.write_pos(7, 1)
      b.update_stages(7)
      b.computer_move(-1)
      expect(b.read_pos(1)).to eq(0)
      expect(b.read_pos(9)).to eq(0)
    end

  end

end
