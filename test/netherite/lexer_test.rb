$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "netherite"

require "minitest/autorun"

module Netherite
  class LexerTest < Minitest::Test

    def test_
      a = Netherite::Lexer.new("12.5+2/(cos(alnc(3))")
      ares = [
        Netherite::Token.new(Netherite::TokenType::NUMBER, 12.5),
        Netherite::Token.new(Netherite::TokenType::PLUS, "+"),
        Netherite::Token.new(Netherite::TokenType::NUMBER, 2),
        Netherite::Token.new(Netherite::TokenType::DIVIDE, "/"),
        Netherite::Token.new(Netherite::TokenType::LPAR, "("),
        Netherite::Token.new(Netherite::TokenType::COS, "cos"),
        Netherite::Token.new(Netherite::TokenType::VAR, "a"),
        Netherite::Token.new(Netherite::TokenType::LN, "ln"),
        Netherite::Token.new(Netherite::TokenType::VAR, "c"),
        Netherite::Token.new(Netherite::TokenType::NUMBER, 3.0),
        Netherite::Token.new(Netherite::TokenType::RPAR, ")"),
        Netherite::Token.new(Netherite::TokenType::RPAR, ")"),
      ]
      assert_equal(ares,a.tokens, "12.5+2/(cos(alnc(3))")
    end
  end
end
