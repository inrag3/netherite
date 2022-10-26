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
    ast.printAST
    simpson(ast, var, a, b)
  end


  private

  def simpson(equation, var, a, b)
    h = (b - a) / 6.0
    res = []
    [a,(a + b) / 2.0, b].each_with_index do |i, index|
      res[index] = -i * Math.cos(i)
    end
    res[1] *= 4.0
    sum = res.sum
    sum * h
  end


end
