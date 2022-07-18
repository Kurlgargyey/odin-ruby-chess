# frozen_string_literal: true

require 'board'

describe Board do
  subject(:board) { described_class.new }
  it 'sets up the Rooks correctly' do
    expect(board.squares[0][0]).to be_a(Rook)
    expect(board.squares[0][7]).to be_a(Rook)
    expect(board.squares[7][0]).to be_a(Rook)
    expect(board.squares[7][7]).to be_a(Rook)
  end

  it 'sets up the Knights correctly' do
    expect(board.squares[0][1]).to be_a(Knight)
    expect(board.squares[0][6]).to be_a(Knight)
    expect(board.squares[7][1]).to be_a(Knight)
    expect(board.squares[7][6]).to be_a(Knight)
  end

  it 'sets up the Bishops correctly' do
    expect(board.squares[0][2]).to be_a(Bishop)
    expect(board.squares[0][5]).to be_a(Bishop)
    expect(board.squares[7][2]).to be_a(Bishop)
    expect(board.squares[7][5]).to be_a(Bishop)
  end

  it 'sets up Queens and Kings correctly' do
    expect(board.squares[0][3]).to be_a(Queen)
    expect(board.squares[0][4]).to be_a(King)

    expect(board.squares[7][3]).to be_a(Queen)
    expect(board.squares[7][4]).to be_a(King)
  end

  it 'sets up the Pawns correctly' do
    expect(board.squares[1]).to all(be_a(Pawn))
    expect(board.squares[6]).to all(be_a(Pawn))
  end

  it 'sets up the colors correctly' do
    [board.squares[0], board.squares[1]].each do |white_rank|
      white_rank.each do |white_piece|
        expect(white_piece.team).to eq(0)
      end
    end

    [board.squares[6], board.squares[7]].each do |black_rank|
      black_rank.each do |black_piece|
        expect(black_piece.team).to eq(1)
      end
    end
  end

  describe '#on_board?' do
    it 'returns true for on-board squares' do
      8.times do |i1|
        8.times do |i2|
          expect(board.on_board?([i1, i2])).to be true
        end
      end
    end

    it 'returns false for off-board squares' do
      8.times do |i|
        expect(board.on_board?([i, 8])).to be false
        expect(board.on_board?([i, -1])).to be false
      end
      8.times do |i|
        expect(board.on_board?([8, i])).to be false
        expect(board.on_board?([-1, i])).to be false
      end
    end
  end

  describe '#blocked?' do
    it 'returns true if there is an ally piece in the way' do
      pawn_double = instance_double('Pawn', team: 0)
      own_team = 0
      target_square = [0, 0]
      allow(board).to receive(:squares).and_return([[pawn_double]])
      expect(board.blocked?(target_square, own_team)).to be true
    end

    it 'returns false if the target square is empty' do
      own_team = 0
      target_square = [0, 0]
      allow(board).to receive(:squares).and_return([[]])
      expect(board.blocked?(target_square, own_team)).to be false
    end

    it 'returns false if there is an enemy piece in the way' do
      pawn_double = instance_double('Pawn', team: 1)
      own_team = 0
      target_square = [0, 0]
      allow(board).to receive(:squares).and_return([[pawn_double]])
      expect(board.blocked?(target_square, own_team)).to be false
    end
  end

  describe '#move_piece' do
    subject(:move_board) { described_class.new }
    it 'makes a normal move' do
      pawn = move_board[[1, 0]]
      move_board.move_piece([3, 0], pawn)
      rook = move_board[[0, 0]]
      expect(move_board[[1, 0]]).to be nil
      expect(move_board[[3, 0]]).to be pawn
      expect(rook.square_legal?([1, 0])).to be true
      expect(move_board.en_passant_square).to eq([2, 0])
    end

    it 'properly does an en passant capture' do
      move_board.place_piece(Pawn.new(0, [4, 1], move_board))
      attacker_pawn = move_board[[4, 1]]
      captured_pawn = move_board[[6, 0]]
      move_board.move_piece([4, 0], captured_pawn)
      expect(move_board.en_passant_square).to eq([5, 0])
      move_board.move_piece([5, 0], attacker_pawn)
      expect(move_board[[5, 0]]).to be attacker_pawn
      expect(move_board[[4, 1]]).to be nil
      expect(move_board[[4, 0]]).to be nil
      expect(move_board.en_passant_square).to be_empty
    end
  end

  describe '#big_rochade' do
    context 'when the rochade is free' do
      board = described_class.new
      board[[0, 1]] = nil
      board[[0, 2]] = nil
      board[[0, 3]] = nil
      pawn = board[[1, 0]]
      board.move_piece([2, 0], pawn)
      subject(:free_queenside_board) { board }
      it "clears the king's old square" do
        expect(free_queenside_board[[0, 4]]).to be_a(King)
        expect(free_queenside_board[[0, 1]]).to be nil
        king = free_queenside_board[[0, 4]]
        expect { free_queenside_board.big_rochade(king) }.to change { free_queenside_board[[0, 4]] }.to be nil
      end

      it "clears the rook's old square" do
        expect(free_queenside_board[[0, 0]]).to be nil
      end

      it 'moves the king' do
        expect(free_queenside_board[[0, 2]]).to be_a(King)
      end

      it 'moves the rook' do
        expect(free_queenside_board[[0, 3]]).to be_a(Rook)
      end
    end

    context 'when the king is in check' do
      board = described_class.new
      board[[0, 1]] = nil
      board[[0, 2]] = nil
      board[[0, 3]] = nil
      pawn = board[[1, 0]]
      board.move_piece([2, 0], pawn)
      subject(:checked_queenside_board) { board }
      before do
        checked_queenside_board.place_piece(Knight.new(1, [2, 3], checked_queenside_board))
      end

      it "does not clear the king's old square" do
        expect(checked_queenside_board[[0, 4]]).to be_a(King)
        expect(checked_queenside_board[[0, 1]]).to be nil
        king = checked_queenside_board[[0, 4]]
        checked_queenside_board.big_rochade(king)
        expect(checked_queenside_board[[0, 4]]).not_to be nil
      end

      it "does not clear the rook's old square" do
        expect(checked_queenside_board[[0, 0]]).not_to be nil
      end

      it 'does not move the king' do
        expect(checked_queenside_board[[0, 2]]).not_to be_a(King)
      end

      it 'does not move the rook' do
        expect(checked_queenside_board[[0, 3]]).not_to be_a(Rook)
      end
    end

    context 'when a transit square is in check' do
      board = described_class.new
      board[[0, 1]] = nil
      board[[0, 2]] = nil
      board[[0, 3]] = nil
      pawn = board[[1, 0]]
      board.move_piece([2, 0], pawn)
      subject(:transit_checked_queenside_board) { board }
      before do
        transit_checked_queenside_board.place_piece(Knight.new(1, [2, 2], transit_checked_queenside_board))
      end

      it "does not clear the king's old square" do
        expect(transit_checked_queenside_board[[0, 4]]).to be_a(King)
        expect(transit_checked_queenside_board[[0, 1]]).to be nil
        king = transit_checked_queenside_board[[0, 4]]
        transit_checked_queenside_board.big_rochade(king)
        expect(transit_checked_queenside_board[[0, 4]]).not_to be nil
      end

      it "does not clear the rook's old square" do
        expect(transit_checked_queenside_board[[0, 0]]).not_to be nil
      end

      it 'does not move the king' do
        expect(transit_checked_queenside_board[[0, 2]]).not_to be_a(King)
      end

      it 'does not move the rook' do
        expect(transit_checked_queenside_board[[0, 3]]).not_to be_a(Rook)
      end
    end
  end

  describe '#small_rochade' do
    subject(:kingside_board) { described_class.new }
  end
end
