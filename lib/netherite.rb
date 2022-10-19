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
  Differentiation.diff("x+y", "x")
end
