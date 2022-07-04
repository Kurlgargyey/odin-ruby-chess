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
      expect(pawn_capture.square_legal?(enemy.position.value)).to be true
    end

    it 'does not allow a random diagonal move' do
      expect(pawn_capture.square_legal?([2, 5])).to be false
    end
  end
end

describe Rook do
  board = Board.new
  subject(:rook) { described_class.new(0, [3, 4], board) }

  it 'allows arbitrary horizontal moves' do
    expect(rook.square_legal?([3, 7])).to be true
    expect(rook.square_legal?([3, 0])).to be true
    expect(rook.square_legal?([3, 5])).to be true
  end

  it 'allows arbitrary vertical moves' do
    expect(rook.square_legal?([2, 4])).to be true
    expect(rook.square_legal?([4, 4])).to be true
    expect(rook.square_legal?([5, 4])).to be true
  end

  it 'does not allow off-board moves' do
    expect(rook.square_legal?([8, 4])).to be false
    expect(rook.square_legal?([-1, 4])).to be false
    expect(rook.square_legal?([3, 8])).to be false
    expect(rook.square_legal?([3, -1])).to be false
  end

  context 'when there is an enemy in the way' do
    it 'allows capture' do
      enemy = Pawn.new(1, [3, 3], board)
      expect(rook.square_legal?(enemy.position.value)).to be true
    end
    it 'does not allow moves past the enemy' do
      enemy = Pawn.new(1, [3, 3], board)
      expect(rook.square_legal?([3, 0])).to be false
    end
  end

  context 'when there is an ally in the way' do
    it 'does not allow move to the occupied square' do
      ally = Pawn.new(0, [3, 3], board)
      expect(rook.square_legal?(ally.position.value)).to be false
    end
    it 'does not allow moves past the ally' do
      ally = Pawn.new(0, [3, 3], board)
      expect(rook.square_legal?([3, 0])).to be false
    end
  end

  context 'at the start of the game' do
    subject(:rook_start) { described_class.new(0, [0, 0], board) }
    it 'does not allow any moves' do
      expect(rook.square_legal?([0, 1])).to be false
      expect(rook.square_legal?([1, 0])).to be false
    end
  end
end
