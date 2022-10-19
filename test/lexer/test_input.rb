require "./test/test_helper"

module Netherite
  class InputTest < Minitest::Test
    def setup
      @lexer = Netherite::Lexer
      @token = Netherite::Token
      @token_type = Netherite::TokenType
    end

    def test_input_wrong_border
      assert_raises(ArgumentError) do
        lexer_tokens = @lexer.new("log(x.y)").tokens
      end
    end

    def test_input_float_typo
      assert_raises(ArgumentError) do
        lexer_tokens = @lexer.new("3..15").tokens
      end
    end
  end
end
