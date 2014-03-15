require 'spec_helper'
require 'board.rb'

describe Board do
  context "#new" do
    it "should initialize a new board" do
      b = Board.new('X')
      expect(b.current_player).to eq('X')
      expect(b.board).to eq([
                             ['.', '.', '.'],
                             ['.', '.', '.'],
                             ['.', '.', '.']])
      expect(b.tos).to eq(%w(. . .
                             . . .
                             . . . X))
    end

  end
end
