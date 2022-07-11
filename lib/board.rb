# frozen_string_literal: true

require_relative 'piece'
require_relative 'vector_math'

class Board
  attr_reader :squares, :pieces_in_play

  def initialize
    @squares = Array.new(8) { Array.new(8) }

    @pieces_in_play = [[], []]
    setup_pieces
  end

  def move_piece(square, piece)
    old_pos = piece.position.value
    piece.move(square)
    set_square_content(piece.position.value, piece)
    set_square_content(old_pos, nil)
    update_pieces(piece)
    piece
  end

  def place_piece(piece)
    set_square_content(piece.position.value, piece)
    @pieces_in_play[piece.team].push(piece)
  end

  def on_board?(square)
    square[0].between?(0, 7) &&
      square[1].between?(0, 7)
  end

  def blocked?(target_square, team)
    content = square_content(target_square)
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

  def square_content(square)
    squares[square[0]][square[1]]
  end

  def set_square_content(square, content)
    squares[square[0]][square[1]] = content
  end

  private

  def update_pieces(moved_piece)
    @pieces_in_play.each do |team|
      team.each do |team_piece|
        team_piece.find_legal_squares(self)
      end
    end
    @pieces_in_play[[0, 1][moved_piece.team - 1]].reject! do |enemy_piece|
      enemy_piece.position.value == moved_piece.position.value
    end
  end

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
