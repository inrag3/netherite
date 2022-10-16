module Netherite

  class Lexer
    def initialize(str)
      @input = str
      @table = { "g" => [0, -1, -1, -1, 0, -1, 0, 0, 0],
                 "t" => [1, 0, 0, 0, 5, 0, 0, 0, 0],
                 "l" => [2, 0, 0, 0, 0, 0, 0, 0, 0],
                 "n" => [0, 0, -1, 0, 0, 0, 0, 0, -1],
                 "s" => [7, 0, 0, 0, 0, 0, -1, 0, 0],
                 "i" => [0, 0, 0, 0, 0, 0, 0, 8, 0],
                 "c" => [4, 0, 0, 0, 0, 0, 0, 0, 0],
                 "o" => [0, 0, 3, 0, 6, 0, 0, 0, 0],
                 "e" => [-1, 0, 0, 0, 0, 0, 0, 0, 0] }
    end

    def tokens
      i = 0
      tokens = []
      while i < @input.size

        char = @input[i]
        case char
        when 'a'..'z'

          temp = ''
          nxt = 0
          flag = false
          while i < @input.size && ('a'..'z').include?(@input[i]) do
            char2 = @input[i]
            if !@table.key?(char2) || @table[char2][nxt] == 0 && @table[char2][0] == 0
              temp.each_char { |a| tokens.push(Token.new(TokenType::VAR, a)) }
              temp.clear
              tokens.push(Token.new(TokenType::VAR, char2))
              nxt = 0

            else
              nxt = @table[char2][nxt]
              if nxt == 0
                temp.each_char { |a| tokens.push(Token.new(TokenType::VAR, a)) }
                temp.clear
                temp += char2
                nxt = @table[char2][nxt]
              else
                temp += char2
              end

              if nxt == -1
                #temp += char2
                case temp
                when 'ln'
                  tokens.push(Token.new(TokenType::LN, temp.clone))
                when 'lg'
                  tokens.push(Token.new(TokenType::LG, temp.clone))
                when 'log'
                  tokens.push(Token.new(TokenType::LOG, temp.clone))
                when 'sin'
                  tokens.push(Token.new(TokenType::SIN, temp.clone))
                when 'cos'
                  tokens.push(Token.new(TokenType::COS, temp.clone))
                when 'ctg'
                  tokens.push(Token.new(TokenType::CTG, temp.clone))
                when 'tg'
                  tokens.push(Token.new(TokenType::TG, temp.clone))
                when 'e'
                  tokens.push(Token.new(TokenType::E, temp.clone))
                end
                nxt = 0
                temp.clear
              end
            end
            i += 1
            flag = true
          end

          if @input.size != i && flag
            i -= 1
          end
          temp.each_char { |a| tokens.push(Token.new(TokenType::VAR, a)) }
          temp.clear
        when '0'..'9'
          j = i
          while ('0'..'9').include?(@input[j]) || @input[j] == '.'
            j += 1
          end
          j -= 1
          tokens.push(Token.new(TokenType::NUMBER, Float(@input[i..j])))
          i = j
        when ','
          tokens.push(Token.new(TokenType::BORDER, char))
        when '+'
          tokens.push(Token.new(TokenType::PLUS, char))
        when '-'
          tokens.push(Token.new(TokenType::MINUS, char))
        when '*'
          tokens.push(Token.new(TokenType::MULTIPLY, char))
        when '/'
          tokens.push(Token.new(TokenType::DIVIDE, char))
        when '('
          tokens.push(Token.new(TokenType::LPAR, char))
        when ')'
          tokens.push(Token.new(TokenType::RPAR, char))
        when '^'
          tokens.push(Token.new(TokenType::POWER, char))
        when /[ \n\t\r]/
        else
          raise ArgumentError.new("Unexpected symbol " + char)
        end
        i += 1
      end

      tokens
    end

    def normalize_tokens(tokens)
      res = []
      i = 0
      while i < tokens.size - 1
        t1 = tokens[i]
        t2 = tokens[i + 1]
        res.push(t1)
        unless t1.operation? || t2.operation? || t1.lpar? || t2.rpar? || t1.border? || t2.border? || (t1.func? && t2.type == TokenType::LPAR)
          res.push(Token.new(TokenType::MULTIPLY, "*"))
        end
        i += 1
      end
      unless tokens.empty?
        res.push tokens[-1]
      end
      res
    end
  end

  class Token
    attr_accessor :type, :value

    def ==(other)
      other.class == Token && other.type == type && other.value == value
    end

    def initialize(type, value)
      @type = type
      @value = value
    end

    def func?
      type == TokenType::LN ||
        type == TokenType::LG ||
        type == TokenType::LOG ||
        type == TokenType::COS ||
        type == TokenType::SIN ||
        type == TokenType::TG ||
        type == TokenType::CTG
    end

    def e?
      type == TokenType::E
    end

    def operation?
      type == TokenType::PLUS ||
        type == TokenType::MINUS ||
        type == TokenType::DIVIDE ||
        type == TokenType::MULTIPLY ||
        type == TokenType::POWER
    end

    def var_number?
      type == TokenType::VAR ||
        type == TokenType::NUMBER ||
        type == TokenType::E
    end

    def lpar?
      type == TokenType::LPAR
    end

    def rpar?
      type == TokenType::RPAR
    end

    def border?
      type == TokenType::BORDER
    end
  end

  module TokenType
    NUMBER = 0
    VAR = 1
    PLUS = 2
    MINUS = 3
    DIVIDE = 4
    MULTIPLY = 5
    POWER = 6
    LPAR = 7
    RPAR = 8
    LN = 9
    LG = 10
    LOG = 11
    COS = 12
    SIN = 13
    TG = 14
    CTG = 15
    E = 16
    BORDER = 17
  end
end
