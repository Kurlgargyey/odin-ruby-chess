# frozen_string_literal: true

require 'board'

class Piece
  attr_reader :team

  def initialize(team, position)
    @team = team
    @position = position.to_a
    @legal_moves = []
    @movement = []
  end

  def move_valid?(move)
    @legal_moves.any?(move)
  end

  private

  attr_reader :position

  def find_legal_moves
    @legal_moves = @movement.map do |move|
      move.zip(position).map do |x, y|
        x + y
      end
    end
    @legal_moves.filter { |move| move[0].between?(0, 7) && move[1].between?(0, 7) }
  end
end

class Pawn < Piece
  def initialize(team, position)
    super(team, position)
    if team.zero?
      @movement.push([0, 1])
      @movement.push([0, 2]) if @position[1] == 1
    else
      @movement.push([0, -1])
      @movement.push([0, -2]) if @position[1] == 6
    end
    find_legal_moves
  end
end

class Rook < Piece
  def initialize(team, position)
    super(team, position)
    @movement.push([0, 1])
    find_legal_moves
  end
end

class Knight < Piece
  def initialize(team, position)
    super(team, position)
    @movement.concat([1, -1].product([2, -2]))
             .concat([2, -2].product([1, -1]))
    find_legal_moves
  end
end

class Bishop < Piece
  def initialize(team, position)
    super(team, position)
    @type = 4
  end
end

class Queen < Piece
  def initialize(team, position)
    super(team, position)
    @type = 5
  end
end

class King < Piece
  def initialize(team, position)
    super(team, position)
    @type = 6
  end
end