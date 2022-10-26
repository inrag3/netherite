require "./lib/netherite/ast_builder"
require "./lib/netherite/lexer"
require "./lib/netherite/postfix_builder"

module Integration
  extend self
  def integrate(equation, var,  a, b)
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
    equation.freeze
    [a, (a + b) / 2.0, b].each_with_index do |i, index|
      dumped = Marshal.load(Marshal.dump(equation))
      res[index] = evaluate(dumped, var, i)
    end
    res[1] = 4.0
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
    case node.parent&.value
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
      calculate_multiply(node.parent)
    else
      # type code here
    end
  end

  def substitution(node, var, i)
    if node.right&.value == var
      token = Netherite::Token.new(Netherite::TokenType::NUMBER, i)
      node.right&.set_token!(token)
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

  def calculate_multiply(node)
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, node.left.value.to_f * node.right.value.to_f)
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def calculate_divide(node)
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, node.left.value.to_f / node.right.value)
    node.replace_node_with_node(Netherite::Node.new(token))
    to_leaf(node)
  end

  def calculate_plus(node)
    token = Netherite::Token.new(Netherite::TokenType::NUMBER, node.left.value.to_f+node.right.value.to_f)
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

  def to_leaf(node)
    node.right = nil
    node.left = nil
  end
end
