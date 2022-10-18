require "./test/test_helper"

module Netherite
  class LexerFuncTest < Minitest::Test
    def setup
      @lexer = Netherite::Lexer
      @token = Netherite::Token
      @token_type = Netherite::TokenType
    end

    def test_basic_func_one_operand
      lexer_tokens = @lexer.new("sin(x)").tokens
      expected_tokens = [
        @token.new(@token_type::SIN, "sin"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::VAR, "x"),
        @token.new(@token_type::RPAR, ")")
      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse sin(x)")
    end

    def test_basic_func_two_operands
      lexer_tokens = @lexer.new("log(a,b)").tokens
      expected_tokens = [
        @token.new(@token_type::LOG, "log"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::VAR, "a"),
        @token.new(@token_type::BORDER, ","),
        @token.new(@token_type::VAR, "b"),
        @token.new(@token_type::RPAR, ")")
      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse log(a,b)")
    end

    def test_func_nested
      lexer_tokens = @lexer.new("log(a,cos(x)/sin(x))").tokens
      expected_tokens = [
        @token.new(@token_type::LOG, "log"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::VAR, "a"),
        @token.new(@token_type::BORDER, ","),
        @token.new(@token_type::COS, "cos"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::VAR, "x"),
        @token.new(@token_type::RPAR, ")"),
        @token.new(@token_type::DIVIDE, "/"),
        @token.new(@token_type::SIN, "sin"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::VAR, "x"),
        @token.new(@token_type::RPAR, ")"),
        @token.new(@token_type::RPAR, ")")
      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse log(a,cos(x)/sin(x))")
    end

    def test_func_nested_two_operands
      lexer_tokens = @lexer.new("log(log(a,b),log(a,b))").tokens
      expected_tokens = [
        @token.new(@token_type::LOG, "log"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::LOG, "log"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::VAR, "a"),
        @token.new(@token_type::BORDER, ","),
        @token.new(@token_type::VAR, "b"),
        @token.new(@token_type::RPAR, ")"),
        @token.new(@token_type::BORDER, ","),
        @token.new(@token_type::LOG, "log"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::VAR, "a"),
        @token.new(@token_type::BORDER, ","),
        @token.new(@token_type::VAR, "b"),
        @token.new(@token_type::RPAR, ")"),
        @token.new(@token_type::RPAR, ")")
      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse log(log(a,b),log(a,b))")
    end

    def test_func_complex_computation
      lexer_tokens = @lexer.new("cos(x*log(a,x)/(5*x-4*y^z))").tokens
      expected_tokens = [
        @token.new(@token_type::COS, "cos"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::VAR, "x"),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::LOG, "log"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::VAR, "a"),
        @token.new(@token_type::BORDER, ","),
        @token.new(@token_type::VAR, "x"),
        @token.new(@token_type::RPAR, ")"),
        @token.new(@token_type::DIVIDE, "/"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::NUMBER, 5),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::VAR, "x"),
        @token.new(@token_type::MINUS, "-"),
        @token.new(@token_type::NUMBER, 4),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::VAR, "y"),
        @token.new(@token_type::POWER, "^"),
        @token.new(@token_type::VAR, "z"),
        @token.new(@token_type::RPAR, ")"),
        @token.new(@token_type::RPAR, ")")
      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse cos(x*log(a,x)/(5*x-4*y^2))")
    end

    def test_input_typo
      lexer_tokens = @lexer.new("log(,b)").tokens
      expected_tokens = [
        @token.new(@token_type::LOG, "log"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::BORDER, ","),
        @token.new(@token_type::VAR, "b"),
        @token.new(@token_type::RPAR, ")")
      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse log(,b)")
    end

    def test_input_typo_complex
      lexer_tokens = @lexer.new("cos4.5()/log(,)x").tokens
      expected_tokens = [
        @token.new(@token_type::COS, "cos"),
        @token.new(@token_type::NUMBER, 4.5),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::RPAR, ")"),
        @token.new(@token_type::DIVIDE, "/"),
        @token.new(@token_type::LOG, "log"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::BORDER, ","),
        @token.new(@token_type::RPAR, ")"),
        @token.new(@token_type::VAR, "x")
      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse cos4()/log(,)x")
    end

    def test_func_float
      lexer_tokens = @lexer.new("3.15*log(66.6,3.2*y)").tokens
      expected_tokens = [
        @token.new(@token_type::NUMBER, 3.15),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::LOG, "log"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::NUMBER, 66.6),
        @token.new(@token_type::BORDER, ","),
        @token.new(@token_type::NUMBER, 3.2),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::VAR, "y"),
        @token.new(@token_type::RPAR, ")")
      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse 3.15*log(66.6,3.2*y)")
    end

    def test_func_e
      lexer_tokens = @lexer.new("abe*elog(a,x^e)").tokens
      expected_tokens = [
        @token.new(@token_type::VAR, "a"),
        @token.new(@token_type::VAR, "b"),
        @token.new(@token_type::E, "e"),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::E, "e"),
        @token.new(@token_type::LOG, "log"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::VAR, "a"),
        @token.new(@token_type::BORDER, ","),
        @token.new(@token_type::VAR, "x"),
        @token.new(@token_type::POWER, "^"),
        @token.new(@token_type::E, "e"),
        @token.new(@token_type::RPAR, ")")
      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse abe*elog(a,x^e)")
    end

    def test_func_nested_pow
      lexer_tokens = @lexer.new("a^(x*y^(3-6))/(b+3^3)").tokens
      expected_tokens = [
        @token.new(@token_type::VAR, "a"),
        @token.new(@token_type::POWER, "^"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::VAR, "x"),
        @token.new(@token_type::MULTIPLY, "*"),
        @token.new(@token_type::VAR, "y"),
        @token.new(@token_type::POWER, "^"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::NUMBER, 3),
        @token.new(@token_type::MINUS, "-"),
        @token.new(@token_type::NUMBER, 6),
        @token.new(@token_type::RPAR, ")"),
        @token.new(@token_type::RPAR, ")"),
        @token.new(@token_type::DIVIDE, "/"),
        @token.new(@token_type::LPAR, "("),
        @token.new(@token_type::VAR, "b"),
        @token.new(@token_type::PLUS, "+"),
        @token.new(@token_type::NUMBER, 3),
        @token.new(@token_type::POWER, "^"),
        @token.new(@token_type::NUMBER, 3),
        @token.new(@token_type::RPAR, ")")
      ]
      assert_equal(lexer_tokens, expected_tokens, "failed parse a^(x*y^(3-6))/(b+3^3)")
    end
  end
end
