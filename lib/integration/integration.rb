require "./lib/netherite/ast_builder"
require "./lib/netherite/lexer"
require "./lib/netherite/postfix_builder"

module Integration
  extend self
  def integrate(equation, var, a, b)
    throw ArgumentError if equation.empty? || var.empty?
    lexer = Netherite::Lexer.new(equation)
    tokens = lexer.normalize_tokens(lexer.fix_unar_operations(lexer.tokens))
    postfix = Netherite::PostfixBuilder.new(tokens)
    ast = Netherite::ASTBuilder.new(postfix.postfix).build
    simpson(ast, var, a, b)
  end

  private
  def simpson(equation, var, a, b)
    h = (b - a) / 6.0
    res = []
    [a, (a + b) / 2.0, b].each_with_index do |i, index|
      dumped = Marshal.load(Marshal.dump(equation))
      res[index] = evaluate(dumped, var, i)
    end
    res[1] *= 4.0
    sum = res.sum
    sum * h
  end

  def evaluate(equation, var, i)
    evaluate_node(equation, var, i)
    equation.value
  end

  def evaluate_node(node, var, i)
    evaluate_node(node.left, var, i) unless node.left.nil?
    evaluate_node(node.right, var, i) unless node.right.nil?
    substitution(node.parent, var, i) unless node.parent.nil?
    if !node.parent.nil? && !node.parent.right.nil? && node.parent.right != node
      evaluate_node(node.parent.right, var, i)
      return
    end
    validation(node.parent) unless node.parent.nil?
    case node.parent&.value
    when "tg"
      calculate_tg(node.parent)
    when "ctg"
      calculate_ctg(node.parent)
    when "log"
      calculate_log(node.parent)
    when "^"
      calculate_power(node.parent)
    when "/"
      calculate_divide(node.parent)
    when "sin"
      calculate_sin(node.parent)
    when "cos"
      calculate_cos(node.parent)
    when "*"
      calculate_multiply(node.parent)
    when "+"
      if node.parent.token.unary_operation?
        calculate_unary_plus(node.parent)
      else
        calculate_plus(node.parent)
      end
    when "-"
      if node.parent.token.unary_operation?
        calculate_unary_minus(node.parent)
      else
        calculate_minus(node.parent)
      end
    else
      if node.parent.nil? && node.left.nil? && node.parent.nil?
      else
        throw ArgumentError
      end
    end
  end

  def validation(node)
    return if node.right.nil? || node.left.nil?

    throw ArgumentError unless node.right.value.is_a?(Numeric)
    throw ArgumentError unless node.left.value.is_a?(Numeric)
  end

  def substitution(node, var, i)
    if node.left&.token&.e?
      token = Netherite::Token.new(Netherite::TokenType::NUMBER, Math::E)
      node.left.set_token!(token)
    end
    if node.right&.token&.e?
      token = Netherite::Token.new(Netherite::TokenType::NUMBER, Math::E)
      node.right.set_token!(token)
    end
    if node.right&.value == var
      token = Netherite::Token.new(Netherite::TokenType::NUMBER, i)
      node.right.set_token!(token)
    end
    if node.left&.value == var
      token = Netherite::Token.new(Netherite::TokenType::NUMBER, i)
      node.left&.set_token!(token)
    end
  end

  def calculate_power(node)
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, node.left.value.to_f**node.right.value.to_f)
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def calculate_e(node)
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, Math::E)
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def calculate_unary_minus(node)
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, -node.left.value.to_f)
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def calculate_unary_plus(node)
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, node.left.value.to_f)
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def calculate_multiply(node)
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, node.left.value.to_f * node.right.value.to_f)
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def calculate_divide(node)
    divider = node.right.value.to_f.zero? ? 1 : node.right.value.to_f
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, node.left.value.to_f / divider)
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def calculate_plus(node)
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, node.left.value.to_f + node.right.value.to_f)
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def calculate_minus(node)
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, node.left.value.to_f - node.right.value.to_f)
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def calculate_sin(node)
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, Math.sin(node.left.value.to_f))
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def calculate_cos(node)
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, Math.cos(node.left.value.to_f))
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def calculate_tg(node)
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, Math.tan(node.left.value.to_f))
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def calculate_ctg(node)
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, 1.0 / Math.tan(node.left.value.to_f))
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def calculate_log(node)
    abort "Извините, мы такую задачу пока не можем решить!" if node.right.value.to_f.negative?
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, Math.log(node.right.value.to_f, node.left.value.to_f))
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def to_leaf(node)
    node.right = nil
    node.left = nil
  end
end
