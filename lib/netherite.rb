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

  pp Integration.integrate('-x*in(x)*x^2+xcos(x^2)*e+sin(3)', 'x', -1, 0)
end

