require "netherite"
require "minitest/autorun"

module Netherite
  class LexerNumericTest < Minitest::Test
    def setup
      @lexer = Netherite::Lexer
      @token = Netherite::Token
      @token_type = Netherite::TokenType
    end

    def test_numeric_one_operand_int
      lexer_instance = @lexer.new("1337")
      expected_tokens = [
        @token.new(@token_type::NUMBER, 1337)
      ]
      assert_equal(lexer_instance.tokens, expected_tokens, "failed parse 1337")
    end

    def test_numeric_one_operand_double
      lexer_instance = @lexer.new("13.37")
      expected_tokens = [
        @token.new(@token_type::NUMBER, 13.37)
      ]
      assert_equal(lexer_instance.tokens, expected_tokens, "failed parse 13.37")
    end

    def test_numeric_two_operands_plus
      lexer_instance = @lexer.new("1337+73.31")
      expected_tokens = [
        @token.new(@token_type::NUMBER, 1337),
        @token.new(@token_type::PLUS, "+"),
        @token.new(@token_type::NUMBER, 73.31)
      ]
      assert_equal(lexer_instance.tokens, expected_tokens, "failed parse 1337+73.31")
    end

    def test_numeric_two_operands_minus
      lexer_instance = @lexer.new("1337-73.31")
      expected_tokens = [
        @token.new(@token_type::NUMBER, 1337),
        @token.new(@token_type::MINUS, "-"),
        @token.new(@token_type::NUMBER, 73.31)
      ]
      assert_equal(lexer_instance.tokens, expected_tokens, "failed parse 1337-73.31")
    end

    def test_numeric_two_operands_mult
      lexer_instance = @lexer.new("1337*73.31")
      expected_tokens = [
        @token.new(@token_type::NUMBER, 1337),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::NUMBER, 73.31)
      ]
      assert_equal(lexer_instance.tokens, expected_tokens, "failed parse 1337*73.31")
    end

    def test_numeric_two_operands_div
      lexer_instance = @lexer.new("1337/73.31")
      expected_tokens = [
        @token.new(@token_type::NUMBER, 1337),
        @token.new(@token_type::DIVIDE, "/"),
        @token.new(@token_type::NUMBER, 73.31)
      ]
      assert_equal(lexer_instance.tokens, expected_tokens, "failed parse 1337/73.31")
    end

    def test_numeric_all_operations
      lexer_instance = @lexer.new("42+666.66*69-1337/7")
      expected_tokens = [
        @token.new(@token_type::NUMBER, 42),
        @token.new(@token_type::PLUS, "+"),
        @token.new(@token_type::NUMBER, 666.66),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::NUMBER, 69),
        @token.new(@token_type::MINUS, "-"),
        @token.new(@token_type::NUMBER, 1337),
        @token.new(@token_type::DIVIDE, "/"),
        @token.new(@token_type::NUMBER, 7)
      ]
      assert_equal(lexer_instance.tokens, expected_tokens, "failed parse 42+666.66*69-1337/7")
    end
  end
end
