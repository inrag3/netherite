# frozen_string_literal: true

require_relative "netherite/version"
require_relative 'netherite/lexer'
require_relative 'netherite/postfix_builder'
require_relative 'netherite/ast_builder'
require_relative 'differentiation/differentiation'
require_relative 'equation'
module Netherite
  class Error < StandardError; end

  # Your code goes here...
  extend Differentiation
  #Differentiation.diff("", "x")
  #Equation.quadratic("2x - 5")
  #Equation.biquadratic("2x^4-5x^2-3")
  #Equation.trigonometric("tg(x) = 1")
  #Equation.cubic("x^3 - 2x^2 - x + 1")

end

# a = Netherite::Lexer.new "cos(x*log(a,x)/(5*x-4*y^z))"
# b = a.normalize_tokens(a.fix_unar_operations(a.tokens))
# c = Netherite::PostfixBuilder.new b
# d = c.postfix
# pp d
# e = Netherite::ASTBuilder.new d
# f = e.build
# pp f
