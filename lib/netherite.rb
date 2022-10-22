# frozen_string_literal: true

require_relative "netherite/version"
require_relative 'netherite/lexer'
require_relative 'netherite/postfix_builder'
require_relative 'netherite/ast_builder'
require_relative 'differentiation/differentiation'

module Netherite
  class Error < StandardError; end

  # Your code goes here...
  extend Differentiation
  Differentiation.diff("5-x", "x")
end

# a = Netherite::Lexer.new "cos(x*log(a,x)/(5*x-4*y^z))"
# b = a.normalize_tokens(a.fix_unar_operations(a.tokens))
# c = Netherite::PostfixBuilder.new b
# d = c.postfix
# pp d
# e = Netherite::ASTBuilder.new d
# f = e.build
# pp f
