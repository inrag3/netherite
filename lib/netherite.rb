# frozen_string_literal: true

require_relative "netherite/version"
require_relative 'netherite/lexer'
require_relative 'netherite/postfix_builder'
require_relative 'netherite/ast_builder'
require_relative 'differentiation/differentiation'
require_relative 'integration/integration'

module Netherite
  class Error < StandardError; end
  extend Differentiation
  extend Integration

  p Integration.integrate('-x*cos(x)', 'x', 0, -1)
end

