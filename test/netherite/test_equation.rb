require 'netherite'
require 'test/test_helper'

class EquationTest < Minitest::Test
  def TestQuadratic
    assert_equal(Equation.biquadratic("x^4 - 10x^2 + 9"),[3,-3,1,-1])
  end
end