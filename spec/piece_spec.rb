# frozen_string_literal: true

require 'piece'

describe Pawn do
  context 'when pawn is white' do
    subject(:pawn) { Pawn.new(0, [0, 2]) }
    it 'allows a 1 square upwards move' do
      expect(pawn.move_valid?([0, 3])).to be true
    end

    it 'does not allow a move greater than 2' do
      expect(pawn.move_valid?([0, 4])).to be false
    end

    it 'does not allow downwards moves' do
      expect(pawn.move_valid?([0, 1])).to be false
    end

    context 'when the pawn has not moved this game' do
      subject(:fresh_pawn) { Pawn.new(0, [0, 1]) }
      it 'allows a double move' do
        expect(fresh_pawn.move_valid?([0, 3])).to be true
      end
    end
  end

  context 'when pawn is black' do
    subject(:pawn) { Pawn.new(1, [0, 5]) }
    it 'allows a 1 square downwards move' do
      expect(pawn.move_valid?([0, 4])).to be true
    end

    it 'does not allow a move greater than 2' do
      expect(pawn.move_valid?([0, 3])).to be false
    end

    it 'does not allow upwards moves' do
      expect(pawn.move_valid?([0, 6])).to be false
    end

    context 'when the pawn has not moved this game' do
      subject(:fresh_pawn) { Pawn.new(1, [0, 6]) }
      it 'allows a double move' do
        expect(fresh_pawn.move_valid?([0, 4])).to be true
      end
    end
  end
end
