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
    curr = stack.pop
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
      @position.children.push(Node.new(result)) if on_board?(result)
    end
    # @legal_moves.filter { |move| on_board?(move) }
    # @legal_moves.filter { |move| unoccupied?(board, move) }
  end

  def on_board?(move)
    move[0].between?(0, 7) && move[1].between?(0, 7)
  end

  def unoccupied?(board, move)
    board.squares[move[0]][move[1]].nil? ||
      board.squares[move[0]][move[1]].team != team
  end
end

class Pawn < Piece
  def initialize(team, position, board)
    super(team, position)
    if team.zero?
      @movement.push([0, 1])
      @movement.push([0, 2]) if @position.value[1] == 1
    else
      @movement.push([0, -1])
      @movement.push([0, -2]) if @position.value[1] == 6
    end
    find_legal_moves(board)
  end

  private

  def find_legal_moves(board)
    super
    @legal_moves
  end
end

class Rook < Piece
  def initialize(team, position, board)
    super(team, position)
    @movement.push([0, 1])
    find_legal_moves(board)
  end
end

class Knight < Piece
  def initialize(team, position, board)
    super(team, position)
    @movement.concat([1, -1].product([2, -2]))
             .concat([2, -2].product([1, -1]))
    find_legal_moves(board)
  end
end

class Bishop < Piece
  def initialize(team, position, board)
    super(team, position)
    @type = 4
  end
end

class Queen < Piece
  def initialize(team, position, board)
    super(team, position)
    @type = 5
  end
end

class King < Piece
  def initialize(team, position, board)
    super(team, position)
    @type = 6
  end
end
