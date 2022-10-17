# frozen_string_literal: true

require_relative "netherite/version"
require_relative 'netherite/lexer'
require_relative 'netherite/postfix_builder'
require_relative 'netherite/ast_builder'

module Netherite
  class Error < StandardError; end

  # Your code goes here...
  def self.hello
    p "hello"
  end
end

=begin
a = Netherite::Lexer.new("ab12clog(e,a)^(2cos(a))")
b = a.tokens
c = a.normalize_tokens b

post = Netherite::PostfixBuilder.new c

pp post.postfix
=end

a = Netherite::Lexer.new("a*blog(e,c)")
b = Netherite::PostfixBuilder.new(a.normalize_tokens(a.fix_unar_operations(a.tokens)))

d = b.postfix
pp d
c = Netherite::ASTBuilder.new d

e = c.build

pp e
=begin
a = Netherite::Lexer.new('+2a-5(-2)+3')
b = a.normalize_tokens(a.fix_unar_operations(a.tokens))
pp b
=end
