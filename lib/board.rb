# frozen_string_literal: true

require 'piece'
require 'matrix'

class Board
  attr_reader :squares

  def initialize(dimensions = 8)
    @squares = Array.new(dimensions) { Array.new(dimensions) }

    setup_pieces
  end

  private

  def setup_pieces
    setup_pawns
    setup_rooks
    setup_knights
    setup_bishops
    setup_queens
    setup_kings
  end

  def setup_pawns
    ranks = [1, 6]
    2.times do |team|
      rank = ranks[team]
      8.times do |file|
        squares[rank][file] = Pawn.new(team, [rank, file], self)
      end
    end
  end

  def setup_rooks
    ranks = [0, 7]
    files = [0, 7]
    2.times do |team|
      rank = ranks[team]
      2.times do |file|
        file = files[file]
        squares[rank][file] = Rook.new(team, [rank, file], self)
      end
    end
  end

  def setup_knights
    ranks = [0, 7]
    files = [1, 6]
    2.times do |team|
      rank = ranks[team]
      2.times do |file|
        file = files[file]
        squares[rank][file] = Knight.new(team, [rank, file], self)
      end
    end
  end

  def setup_bishops
    ranks = [0, 7]
    files = [2, 5]
    2.times do |team|
      rank = ranks[team]
      2.times do |file|
        file = files[file]
        squares[rank][file] = Bishop.new(team, [rank, file], self)
      end
    end
  end

  def setup_queens
    ranks = [0, 7]
    2.times do |team|
      rank = ranks[team]
      file = 3
      squares[rank][file] = Queen.new(team, [rank, file], self)
    end
  end

  def setup_kings
    ranks = [0, 7]
    2.times do |team|
      rank = ranks[team]
      file = 4
      squares[rank][file] = King.new(team, [rank, file], self)
    end
  end
end
