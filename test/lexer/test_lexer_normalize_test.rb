require "./test/test_helper"

module Netherite
  class LexerNormalizeTest < Minitest::Test
    def setup
      @lexer = Netherite::Lexer
      @norm = Netherite::Lexer.new("")
      @token = Netherite::Token
      @token_type = Netherite::TokenType
    end

    def test_normalize_simple
      lexer_tokens = @lexer.new("15x").tokens
      lexer_tokens = @norm.normalize_tokens(lexer_tokens)

      expected_tokens = [
        @token.new(@token_type::NUMBER, 15),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::VAR, "x")
      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse 15x")
    end

    def test_normalize_nested
      lexer_tokens = @lexer.new("3cos(15x + 2log(a,3b)").tokens
      lexer_tokens = @norm.normalize_tokens(lexer_tokens)
      expected_tokens = [
        @token.new(@token_type::NUMBER, 3),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::COS, "cos"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::NUMBER, 15),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::VAR, "x"),
        @token.new(@token_type::PLUS, "+"),
        @token.new(@token_type::NUMBER, 2),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::LOG, "log"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::VAR, "a"),
        @token.new(@token_type::BORDER, ","),
        @token.new(@token_type::NUMBER, 3),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::VAR, "b"),
        @token.new(@token_type::RPAR, ")")
      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse 3cos(15x + 2log(a,3b)")
    end

    def test_normalize_repeating_ops
      lexer_tokens = @lexer.new("5*10*5x+3.1*2.2y").tokens
      lexer_tokens = @norm.normalize_tokens(lexer_tokens)

      expected_tokens = [
        @token.new(@token_type::NUMBER, 5),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::NUMBER, 10),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::NUMBER, 5),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::VAR, "x"),

        @token.new(@token_type::PLUS, "+"),

        @token.new(@token_type::NUMBER, 3.1),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::NUMBER, 2.2),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::VAR, "y")
      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse 5*10*5x+3.1*2.2y")
    end

    def test_normalize_funcs
      lexer_tokens = @lexer.new("3e+5ln(2a)-3.3ctg(6.6a)").tokens
      lexer_tokens = @norm.normalize_tokens(lexer_tokens)

      expected_tokens = [
        @token.new(@token_type::NUMBER, 3),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::E, "e"),
        @token.new(@token_type::PLUS, "+"),
        @token.new(@token_type::NUMBER, 5),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::LN, "ln"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::NUMBER, 2),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::VAR, "a"),
        @token.new(@token_type::RPAR, ")"),
        @token.new(@token_type::MINUS, "-"),
        @token.new(@token_type::NUMBER, 3.3),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::CTG, "ctg"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::NUMBER, 6.6),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::VAR, "a"),
        @token.new(@token_type::RPAR, ")"),

      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse 3e+5ln(2a)-3.3ctg(6.6a)")
    end

    def test_normalize_division
      lexer_tokens = @lexer.new("6x/3(4y-3/4x)").tokens
      lexer_tokens = @norm.normalize_tokens(lexer_tokens)

      expected_tokens = [
        @token.new(@token_type::NUMBER, 6),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::VAR, "x"),
        @token.new(@token_type::DIVIDE, "/"),
        @token.new(@token_type::NUMBER, 3),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::NUMBER, 4),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::VAR, "y"),
        @token.new(@token_type::MINUS, "-"),
        @token.new(@token_type::NUMBER, 3),
        @token.new(@token_type::DIVIDE, "/"),
        @token.new(@token_type::NUMBER, 4),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::VAR, "x"),
        @token.new(@token_type::RPAR, ")")
      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse 6x/3(4y-3/4x)")
    end

  end
end
