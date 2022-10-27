# frozen_string_literal: true

require_relative "netherite/version"
require_relative 'netherite/lexer'
require_relative 'netherite/postfix_builder'
require_relative 'netherite/ast_builder'
require_relative 'differentiation/differentiation'
require_relative 'integration/integration'
require_relative 'equation'
module Netherite
  extend Differentiation
  extend Equation
  extend Integration
end