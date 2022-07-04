# frozen_string_literal: true

require 'vector_math'
require 'node'
require 'board'

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

  def find_legal_squares(board)
    @moves.each do |move|
      result = VectorAdd(move, position.value)
      add_legal_square(result) if validate_move(result, board)
    end
  end

  def validate_move(move, board)
    board.on_board?(move) && !board.blocked?(move, team)
  end

  def enemy_found?(board, square)
    content = board.square_content(square)
    !content.nil? && content.team != team
  end

  def add_legal_square(square)
    @position.children.push(Node.new(square))
  end

  def compile_moves; end
end

class Pawn < Piece
  def to_s
    !team.zero? ? "\u2659" : "\u265F"
  end

  private

  def pawn_direction
    team.zero? ? 1 : -1
  end

  def pawn_hasnt_moved
    @position.value[0] == 1 && team.zero? ||
      @position.value[0] == 6 && team == 1
  end

  def compile_moves
    move = pawn_direction
    @moves.push([move, 0])
    @moves.push([move * 2, 0]) if pawn_hasnt_moved
  end

  def find_legal_squares(board)
    super(board)
    find_pawn_capture_squares(board)
  end

  def find_pawn_capture_squares(board)
    target_rank = position.value[0] + pawn_direction
    [1, -1].each do |diag|
      target_file = position.value[1] + diag
      add_legal_square([target_rank, target_file]) if enemy_found?(board, [target_rank, target_file])
    end
  end
end

class Rook < Piece
  def initialize(team, position, board)
    super(team, position, board)
    @moves.push([0, 1])
    find_legal_squares(board)
  end

  def to_s
    !team.zero? ? "\u2656" : "\u265C"
  end
end

class Knight < Piece
  def initialize(team, position, board)
    super(team, position, board)
    @moves.concat([1, -1].product([2, -2]))
             .concat([2, -2].product([1, -1]))
    find_legal_squares(board)
  end

  def to_s
    !team.zero? ? "\u2658" : "\u265E"
  end
end

class Bishop < Piece
  def initialize(team, position, board)
    super(team, position, board)
    @type = 4
  end

  def to_s
    !team.zero? ? "\u2657" : "\u265D"
  end
end

class Queen < Piece
  def initialize(team, position, board)
    super(team, position, board)
    @type = 5
  end

  def to_s
    !team.zero? ? "\u2655" : "\u265B"
  end
end

class King < Piece
  def initialize(team, position, board)
    super(team, position, board)
    @type = 6
  end

  def to_s
    !team.zero? ? "\u2654" : "\u265A"
  end
end
