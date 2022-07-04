# frozen_string_literal: true

require 'piece'
require 'matrix'

class Board
  attr_reader :squares

  def initialize
    @squares = Array.new(8) { Array.new(8) }

    @pieces_in_play = [[], []]
    setup_pieces
  end

  def place_piece(piece)
    rank = piece.position.value[0]
    file = piece.position.value[1]
    squares[rank][file] = piece
    @pieces_in_play[piece.team].push(piece)
  end

  def on_board?(square)
    square[0].between?(0, 7) &&
      square[1].between?(0, 7)
  end

  def blocked?(target_square, team)
    target_rank = target_square[0]
    target_file = target_square[1]

    content = squares[target_rank][target_file]
    return content if content.nil?
    return false if content.team != team

    true
  end

  def print_board
    @squares.reverse.each.with_index do |rank, idx|
      print_rank(rank, idx)
    end
    print_footer
  end

  private

  def print_rank(rank, idx)
    print "   #{'+---' * 8}+\n#{8 - idx}  "
    rank.each do |square|
      print "| #{square || ' '} "
    end
    print "|\n"
  end

  def print_footer
    alphabet = ('a'..'z').to_a
    print "   #{'+---' * 8}+\n   "
    8.times do |i|
      print "  #{alphabet[i]} "
    end
    print "\n\n"
  end

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
        Pawn.new(team, [rank, file], self)
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
        Rook.new(team, [rank, file], self)
      end
    end
  end

  def setup_knights
    ranks = [0, 7]
    files = [1, 6]
    2.times do |team|
      rank = ranks[team]
      2.times do |switch|
        file = files[switch]
        Knight.new(team, [rank, file], self)
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
        Bishop.new(team, [rank, file], self)
      end
    end
  end

  def setup_queens
    ranks = [0, 7]
    2.times do |team|
      rank = ranks[team]
      file = 3
      Queen.new(team, [rank, file], self)
    end
  end

  def setup_kings
    ranks = [0, 7]
    2.times do |team|
      rank = ranks[team]
      file = 4
      King.new(team, [rank, file], self)
    end
  end
end
