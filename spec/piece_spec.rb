# frozen_string_literal: true

require 'board'
require 'piece'

describe Pawn do
  board = Board.new
  context 'when pawn is white' do
    subject(:pawn) { Pawn.new(0, [2, 2], board) }

    it 'allows a 1 square upwards move' do
      expect(pawn.square_legal?([3, 2])).to be true
    end

    it 'does not allow a move greater than 2' do
      expect(pawn.square_legal?([4, 2])).to be false
    end

    it 'does not allow downwards moves' do
      expect(pawn.square_legal?([1, 2])).to be false
    end

    context 'when the pawn has not moved this game' do
      subject(:fresh_pawn) { Pawn.new(0, [1, 1], board) }
      it 'allows a double move' do
        expect(fresh_pawn.square_legal?([3, 1])).to be true
      end
    end
  end

  context 'when pawn is black' do
    subject(:pawn) { Pawn.new(1, [5, 5], board) }
    it 'allows a 1 square downwards move' do
      expect(pawn.square_legal?([4, 5])).to be true
    end

    it 'does not allow a move greater than 2' do
      expect(pawn.square_legal?([3, 5])).to be false
    end

    it 'does not allow upwards moves' do
      expect(pawn.square_legal?([6, 5])).to be false
    end

    context 'when the pawn has not moved this game' do
      subject(:fresh_pawn) { Pawn.new(1, [6, 5], board) }
      it 'allows a double move' do
        expect(fresh_pawn.square_legal?([4, 5])).to be true
      end
    end
  end

  context 'when there is an enemy diagonally in front' do
    board = Board.new
    subject(:pawn_capture) { Pawn.new(0, [1, 4], board) }
    enemy = Pawn.new(1, [2, 3], board)

    it 'allows a diagonal capture' do
      expect(pawn_capture.square_legal?([2, 3])).to be true
      board.print_board
    end

    it 'does not allow a random diagonal move' do
      expect(pawn_capture.square_legal?([2, 5])).to be false
    end
  end
end

describe Rook do
  board = Board.new
  subject(:rook) { Rook.new(0, [0, 0], board) }
end
