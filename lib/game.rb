# frozen_string_literal: true

class Game
  def initialize
    @history = +''
  end

  def run
    turn = 1
    move = gets.chomp
    until move.empty?
      @history << "#{turn}.#{move} "
      move = gets.chomp
      @history << "#{move} " unless move.empty?
      turn += 1
      move = gets.chomp
    end
  end
end
