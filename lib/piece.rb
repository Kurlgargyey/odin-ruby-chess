# frozen_string_literal: true

require_relative 'vector_math'
require_relative 'node'
require_relative 'board'

class Piece
  include VectorMathInArrays

  attr_reader :team, :position

  def initialize(team, position, board)
    @team = team
    @position = Node.new(position)
    @moves = []
    compile_moves
    find_legal_squares(board)
    board.place_piece(self)
  end

  def square_legal?(move)
    tree_contains?(move)
  end

  def move(square)
    @position = Node.new(square)
  end

  def find_legal_squares(board)
    @position.children = []
    @moves.each do |move|
      result = vector_add(move, position.value)
      add_legal_square(result) if validate_square(result, board)
    end
  end

  private

  def tree_contains?(move)
    stack = []
    @position.children.each { |child| stack.push(child) }
    curr = stack.shift
    while curr
      return true if curr.value == move

      curr.children.each { |child| stack.push(child) }
      curr = stack.pop
    end
    false
  end

  def validate_square(square, board)
    board.on_board?(square) && !board.blocked?(square, team)
  end

  def enemy_found?(target_square, board)
    content = board[target_square]
    !content.nil? && content.team != team
  end

  def add_legal_square(square)
    @position.children.push(Node.new(square))
  end

  def compile_moves; end
end

class Pawn < Piece
  attr_reader :first_move

  def initialize(team, position, board)
    @first_move = true
    super(team, position, board)
  end

  def to_s
    !team.zero? ? "\u2659" : "\u265F"
  end

  def find_legal_squares(board)
    @position.children = []
    result = vector_add(@moves[0], position.value)
    add_legal_square(result) if validate_square(result, board)
    add_first_move(board)
    find_pawn_capture_squares(board)
  end

  def move(square)
    @first_move = false
    super(square)
  end

  def promotion?
    promo_ranks = [7, 0]
    position.value[0] == promo_ranks[team]
  end

  private

  def pawn_direction
    team.zero? ? 1 : -1
  end

  def compile_moves
    direction = pawn_direction
    @moves.push([direction, 0])
  end

  def add_first_move(board)
    return unless first_move

    result = vector_add(vector_scale(@moves[0], 2), position.value)
    add_legal_square(result) if validate_square(result, board)
  end

  def find_pawn_capture_squares(board)
    target_rank = position.value[0] + pawn_direction
    [1, -1].each do |diag|
      target_file = position.value[1] + diag
      if enemy_found?([target_rank, target_file], board) ||
         en_passant?([target_rank, target_file], board)
        add_legal_square([target_rank, target_file])
      end
    end
  end

  def en_passant?(target_square, board)
    target_square == board.en_passant_square
  end

  def validate_square(square, board)
    return false unless board.on_board?(square)
    return true unless board[square]

    false
  end
end

class Rook < Piece
  attr_reader :has_moved

  def initialize(team, position, board)
    super(team, position, board)
    @has_moved = false
  end

  def to_s
    !team.zero? ? "\u2656" : "\u265C"
  end

  def find_legal_squares(board)
    @moves.each do |dir|
      result = vector_add(dir, position.value)
      while validate_square(result, board)
        add_legal_square(result)
        break if enemy_found?(result, board)

        result = vector_add(dir, result)
      end
    end
  end

  def move(square)
    super(square)
    @has_moved = true
  end

  private

  def compile_moves
    @moves = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1]
    ]
  end
end

class Knight < Piece
  def to_s
    !team.zero? ? "\u2658" : "\u265E"
  end

  private

  def compile_moves
    @moves.concat([1, -1].product([2, -2]))
          .concat([2, -2].product([1, -1]))
  end
end

class Bishop < Piece
  def to_s
    !team.zero? ? "\u2657" : "\u265D"
  end

  def find_legal_squares(board)
    @moves.each do |dir|
      result = vector_add(dir, position.value)
      while validate_square(result, board)
        add_legal_square(result)
        break if enemy_found?(result, board)

        result = vector_add(dir, result)
      end
    end
  end

  private

  def compile_moves
    @moves = [
      [1, 1],
      [-1, 1],
      [1, -1],
      [-1, -1]
    ]
  end
end

class Queen < Piece
  def to_s
    !team.zero? ? "\u2655" : "\u265B"
  end

  def find_legal_squares(board)
    @moves.each do |dir|
      result = vector_add(dir, position.value)
      while validate_square(result, board)
        add_legal_square(result)
        break if enemy_found?(result, board)

        result = vector_add(dir, result)
      end
    end
  end

  def move(square)
    super(square)
  end

  private

  def compile_moves
    @moves = [
      [1, 1],
      [-1, 1],
      [1, -1],
      [-1, -1],
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1]
    ]
  end
end

class King < Piece
  attr_reader :has_moved

  def initialize(team, position, board)
    super(team, position, board)
    @has_moved = false
  end

  def to_s
    !team.zero? ? "\u2654" : "\u265A"
  end

  def move(square)
    super(square)
    @has_moved = true
  end

  def find_legal_squares(board)
    super(board)
    add_legal_square([position.value[0], 2]) if big_rochade_check(board)
    add_legal_square([position.value[0], 6]) if small_rochade_check(board)
  end

  def check?(board, square = position.value)
    enemy_pieces = board.pieces_in_play[[0, 1][team - 1]]
    checking_pieces = []
    enemy_pieces.each do |piece|
      checking_pieces << piece if piece.square_legal?(square)
    end
    !checking_pieces.empty?
  end

  def checkmate?(board)
    position.children.empty? && check?(board)
  end

  def small_rochade(board)
    return unless small_rochade_check(board)

    board.move_piece([position.value[0], 6], self)
    board.move_piece([position.value[0], 5], board[[position.value[0], 7]])
    'o-o'
  end

  def big_rochade(board)
    return unless big_rochade_check(board)

    board.move_piece([position.value[0], 2], self)
    board.move_piece([position.value[0], 3], board[[position.value[0], 0]])
    'O-O'
  end

  private

  def small_rochade_check(board)
    corner_piece = board[[position.value[0], 7]]
    return false unless corner_piece.is_a?(Rook)
    return false if has_moved
    return false if corner_piece.has_moved
    return false unless small_rochade_free?(board)

    true
  end

  def small_rochade_free?(board)
    return false if check?(board)

    2.times do |i|
      square = [position.value[0], position.value[1] + 1 + i]
      return false if board[square]
      return false if check?(board, square)
    end

    true
  end

  def big_rochade_check(board)
    corner_piece = board[[position.value[0], 0]]
    return false unless corner_piece.is_a?(Rook)
    return false if has_moved
    return false if corner_piece.has_moved
    return false unless big_rochade_free?(board)

    true
  end

  def big_rochade_free?(board)
    return false if check?(board)

    2.times do |i|
      square = [position.value[0], position.value[1] - 1 - i]
      return false if board[square]
      return false if check?(board, square)
    end

    true
  end

  def compile_moves
    @moves = [
      [1, 1],
      [-1, 1],
      [1, -1],
      [-1, -1],
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1]
    ]
  end

  def validate_square(square, board)
    return false unless super(square, board)
    return false if check?(board, square)

    true
  end
end
