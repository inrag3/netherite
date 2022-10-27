require "./test/test_helper"


class IntegrationTest < Minitest::Test
  TOLERANCE = 0.001

  def test_empty_agrument
    assert_raises(ArgumentError) do
      Netherite.integrate('','x',0,0)
    end
  end

  def test_empty_variable
    assert_raises(ArgumentError) do
      Netherite.integrate('log(2,3)','',0,0)
    end
  end

  def test_wrong_variable
    assert_raises(ArgumentError) do
      Netherite.integrate('y*cos(y)','x',-1, 2)
    end
  end

  def test_wrong_argument2
    assert_raises(ArgumentError) do
      Netherite.integrate('y*cy)','x',-1, 2)
    end
  end

  def test_simple_cos
    assert_operator((0.02207 - Netherite.integrate('y*cos(y)','y',1, 2)).abs, :<, TOLERANCE)
  end

  def test_simple_log
    assert_operator((5.889975 - Netherite.integrate('x^2+3+log(2,x)','x',1, 2)).abs, :<, TOLERANCE)
  end

  def test_unary_operation
    assert_operator((-0.02208 - Netherite.integrate('+3-xcos(x)-3','x',1, 2)).abs, :<, TOLERANCE)
  end

  def test_simple_sin
    assert_operator((1.4408 - Netherite.integrate('x*sin(x)','x', 1, 2)).abs, :<, TOLERANCE)
  end

  def test_simple_divide
    assert_operator((Netherite.integrate('x*sin(x)+2','x', 1, 2) - Netherite.integrate('x*sin(x)+10/5','x', 1, 2)).abs, :<, TOLERANCE)
  end

  def test_complicated_1
    assert_operator(2.02469 - (Netherite.integrate('x*sin(x)+10/25++cos(x)*e','x', 1, 2)).abs, :<, TOLERANCE)
  end

  def test_complicated_2
    assert_operator(2.51956 - (Netherite.integrate('(x*sin(x)+10/25++cos(x)*e)*(e*ctg(2))','x', 1, 2)).abs, :<, TOLERANCE)
  end
end
