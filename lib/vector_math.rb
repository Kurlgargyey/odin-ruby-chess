# frozen_string_literal: true

module VectorMathInArrays
  def vector_add(arr1, arr2)
    arr1.zip(arr2).map do |x, y|
      x + y
    end
  end
end
