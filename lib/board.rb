# frozen_string_literal: true

require_relative 'piece'
require_relative 'vector_math'

class Board
  attr_reader :squares, :pieces_in_play, :en_passant_square

  def initialize
    @squares = Array.new(8) { Array.new(8) }
    @en_passant_square = []

    @pieces_in_play = [[], []]
    setup_pieces
  end

  def move_piece(square, piece)
    old_pos = piece.position.value
    capture_en_passant(piece, square) if piece.is_a?(Pawn) && square == en_passant_square
    update_en_passant(piece, square)
    piece.move(square)
    update_board(old_pos, piece)
    piece
  end

  def place_piece(piece)
    self[piece.position.value] = piece
    @pieces_in_play[piece.team].push(piece)
  end

  def on_board?(square)
    square[0].between?(0, 7) &&
      square[1].between?(0, 7)
  end

  def blocked?(target_square, team)
    content = self[target_square]
    return false unless content
    return false unless content.team == team

    true
  end

  def print_board
    @squares.reverse.each.with_index do |rank, idx|
      print_rank(rank, idx)
    end
    print_footer
  end

  def [](square)
    squares[square[0]][square[1]]
  end

  def []=(square, content)
    squares[square[0]][square[1]] = content
  end

  private

  def update_board(old_pos, piece)
    self[piece.position.value] = piece
    self[old_pos] = nil
    promotion_prompt(piece) if piece.is_a?(Pawn) && piece.promotion?
    update_pieces
    update_moves
  end

  def promotion_prompt(piece)
    puts 'Your pawn has been promoted!'
    puts 'Which piece would you like?'
    puts '(Q)ueen, (R)ook, (B)ishop or K(N)ight?'
    promotion(piece)
  end

  def promotion(piece)
    piece_map = {
      'R' => Rook,
      'K' => Knight,
      'B' => Bishop,
      'Q' => Queen
    }
    selection = gets.chomp.upcase! until piece_map.include?(selection)
    place_piece(piece_map[selection].new(piece.team, piece.position.value, self))
  end

  def capture_en_passant(piece, square)
    ranks = [4, 3]
    file = square[1]
    self[ranks[piece.team], file] = nil
  end

  def update_en_passant(piece, square)
    return @en_passant_square = [] unless piece.is_a?(Pawn)
    return @en_passant_square = [] unless piece.first_move
    return @en_passant_square = [] unless (piece.position.value[0] - square[0]).abs == 2

    ranks = [2, 5]
    file = piece.position.value[1]
    @en_passant_square = [ranks[piece.team], file]
  end

  def update_pieces
    @pieces_in_play = [[], []]
    @squares.each do |rank|
      rank.each do |piece|
        @pieces_in_play[piece.team].push(piece) if piece
      end
    end
  end

  def update_moves
    @pieces_in_play.each do |team|
      team.each do |team_piece|
        team_piece.find_legal_squares(self)
      end
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
