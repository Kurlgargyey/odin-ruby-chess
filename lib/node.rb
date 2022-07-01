# frozen_string_literal: true

class Node
  attr_accessor :children, :value

  def initialize(position)
    @value = position
    @children = []
  end
end