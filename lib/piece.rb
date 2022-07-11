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
    content = board.square_content(target_square)
    !content.nil? && content.team != team
  end

  def add_legal_square(square)
    @position.children.push(Node.new(square))
  end

  def compile_moves; end
end

class Pawn < Piece
  def initialize(team, position, board)
    super(team, position, board)
    @has_moved = false
  end

  def to_s
    !team.zero? ? "\u2659" : "\u265F"
  end

  def find_legal_squares(board)
    super(board)
    find_pawn_capture_squares(board)
  end

  def move(square)
    super(square)
    @has_moved = true
  end

  private

  def pawn_direction
    team.zero? ? 1 : -1
  end

  def compile_moves
    direction = pawn_direction
    @moves.push([direction, 0])
    @moves.push([direction * 2, 0]) if @has_moved
  end

  def find_pawn_capture_squares(board)
    target_rank = position.value[0] + pawn_direction
    [1, -1].each do |diag|
      target_file = position.value[1] + diag
      add_legal_square([target_rank, target_file]) if enemy_found?([target_rank, target_file], board)
    end
  end
end

class Rook < Piece
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
    @has_moved = true
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
  def initialize(team, position, board)
    super(team, position, board)
    @has_moved = false
  end

  def to_s
    !team.zero? ? "\u2654" : "\u265A"
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

  def rochade()
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

  def validate_square(square, board)
    enemy_pieces = board.pieces_in_play[[0, 1][team - 1]]
    board.on_board?(square) &&
      !board.blocked?(square, team) &&
      enemy_pieces.any? { |piece| piece.square_legal?(square) }
  end
end
