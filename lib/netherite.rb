# frozen_string_literal: true

require_relative "netherite/version"
require_relative 'netherite/lexer'
require_relative 'netherite/postfix_builder'

module Netherite
  class Error < StandardError; end
  # Your code goes here...
  def self.hello
    p "hello"
  end
end

a = Netherite::Lexer.new("ab12clog(e,a)^(2cos(a))")
b = a.tokens
c = a.normalize_tokens b

post = Netherite::PostfixBuilder.new c

pp post.postfix