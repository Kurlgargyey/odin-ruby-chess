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

    it 'returns nil if the target square is empty' do
      own_team = 0
      target_square = [0, 0]
      allow(board).to receive(:squares).and_return([[]])
      expect(board.blocked?(target_square, own_team)).to be nil
    end

    it 'returns false if there is an enemy piece in the way' do
      pawn_double = instance_double('Pawn', team: 1)
      own_team = 0
      target_square = [0, 0]
      allow(board).to receive(:squares).and_return([[pawn_double]])
      expect(board.blocked?(target_square, own_team)).to be false
    end
  end
end
