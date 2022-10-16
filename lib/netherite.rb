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

a = Netherite::Lexer.new("ab12clog(e,a)^(2cos(a)")
b = a.tokens
p a.normalize_tokens b