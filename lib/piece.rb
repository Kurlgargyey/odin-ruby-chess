# frozen_string_literal: true

require 'vector_math'
require 'node'
require 'board'

class Piece
  include VectorMathInArrays

  attr_reader :team

  def initialize(team, position)
    @team = team
    @position = Node.new(position)
    @movement = []
  end

  def move_valid?(move)
    tree_contains?(move)
  end

  private

  attr_reader :position

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

  def find_legal_moves(board)
    @movement.each do |move|
      result = VectorAdd(move, position.value)
      if board.on_board?(result) && !board.blocked?(result, team)
        @position.children.push(Node.new(result))
      end
    end
    # @legal_moves.filter { |move| on_board?(move) }
    # @legal_moves.filter { |move| unoccupied?(board, move) }
  end
end

class Pawn < Piece
  def initialize(team, position, board)
    super(team, position)
    if team.zero?
      @movement.push([1, 0])
      @movement.push([2, 0]) if @position.value[0] == 1
    else
      @movement.push([-1, 0])
      @movement.push([-2, 0]) if @position.value[0] == 6
    end
    find_legal_moves(board)
  end

  def to_s
    !team.zero? ? "\u2659" : "\u265F"
  end

  private

  def find_legal_moves(board)
    super
  end
end

class Rook < Piece
  def initialize(team, position, board)
    super(team, position)
    @movement.push([0, 1])
    find_legal_moves(board)
  end

  def to_s
    !team.zero? ? "\u2656" : "\u265C"
  end
end

class Knight < Piece
  def initialize(team, position, board)
    super(team, position)
    @movement.concat([1, -1].product([2, -2]))
             .concat([2, -2].product([1, -1]))
    find_legal_moves(board)
  end

  def to_s
    !team.zero? ? "\u2658" : "\u265E"
  end
end

class Bishop < Piece
  def initialize(team, position, board)
    super(team, position)
    @type = 4
  end

  def to_s
    !team.zero? ? "\u2657" : "\u265D"
  end
end

class Queen < Piece
  def initialize(team, position, board)
    super(team, position)
    @type = 5
  end

  def to_s
    !team.zero? ? "\u2655" : "\u265B"
  end
end

class King < Piece
  def initialize(team, position, board)
    super(team, position)
    @type = 6
  end

  def to_s
    !team.zero? ? "\u2654" : "\u265A"
  end
end
