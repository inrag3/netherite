# frozen_string_literal: true

require_relative "netherite/version"
require_relative 'netherite/lexer'

module Netherite
  class Error < StandardError; end
  # Your code goes here...
  def self.hello
    p "hello"
  end
end

a = Netherite::Lexer.new("ab12cloge(a)")
p a.tokens