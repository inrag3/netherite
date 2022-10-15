module Netherite
  class Lexer
    def initialize(str)
      @input = str
      @table = { 'g': [0, -1, -1, -1, 0, -1, 0, 0, 0],
                 't': [1, 0, 0, 0, 5, 0, 0, 0, 0],
                 'l': [2, 0, 0, 0, 0, 0, 0, 0, 0],
                 'n': [0, 0, -1, 0, 0, 0, 0, 0, -1],
                 's': [7, 0, 0, 0, 0, 0, -1, 0, 0],
                 'i': [0, 0, 0, 0, 0, 0, 0, 8, 0],
                 'c': [4, 0, 0, 0, 0, 0, 0, 0, 0],
                 'o': [0, 0, 3, 0, 6, 0, 0, 0, 0]
      }
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
          while ('a'..'z').include?(@input[i]) && i < @input.size
            nxt = @table[@input[i]][nxt]
            if nxt == -1
              case temp
              when 'ln'
                Token.push(Token.new(TokenType::LN, temp))
              when 'lg'
                Token.push(Token.new(TokenType::LG, temp))
              when 'log'
                Token.push(Token.new(TokenType::LOG, temp))
              when 'sin'
                Token.push(Token.new(TokenType::SIN, temp))
              when 'cos'
                Token.push(Token.new(TokenType::COS, temp))
              when 'ctg'
                Token.push(Token.new(TokenType::CTG, temp))
              when 'tg'
                Token.push(Token.new(TokenType::TG, temp))
              end
            end
            if nxt == 0
              temp.each { |a| tokens.push(Token.new(TokenType::VAR, a)) }
              temp.clear
            end
            temp += @input[i]
            i += 1
          end

          temp.each { |a| tokens.push(Token.new(TokenType::VAR, a)) }
          temp.clear
        when '0'..'9'
          j = i
          while ('0'..'9').include?(@input[j])
            j += 1
          end
          j -= 1
          tokens.push(Token.new(TokenType::NUMBER, Float(@input[i..j])))
          i = j
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
  end

  class Token
    attr_accessor :type, :value

    def initialize(type, value)
      @type = type
      @value = value
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
  end
end
