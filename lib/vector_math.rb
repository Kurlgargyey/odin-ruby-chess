# frozen_string_literal: true

module VectorMathInArrays

  def VectorAdd(arr1, arr2)
    result = arr1.zip(arr2).map do |x, y|
      x + y
    end
    result
  end
end