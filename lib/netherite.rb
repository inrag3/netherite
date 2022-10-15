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

l = Netherite::Lexer.new("avscosa")
p l.tokens