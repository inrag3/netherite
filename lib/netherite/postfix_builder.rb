module Netherite
  class BuildPostfixException < RuntimeError; end

  class PostfixBuilder
    def initialize(tokens)
      @tokens = tokens
    end

    def postfix
      res = []
      stack = []
      @tokens.each do |el|
        if el.var_number?
          res.push el
        elsif el.func?
          stack << el
        elsif el.border?
          while !stack.empty? && !stack.last.lpar?
            res.push stack.pop
          end
          throw BuildPostfixException if stack.empty? # ошибка поиска открывающей скобки при нахлждении разделителя
          #stack.pop
        elsif el.operation?
          p1 = priority el
          while !stack.empty? && stack.last.operation? && p1 <= priority(stack.last)
            res.push(stack.pop)
          end
          stack << el
        elsif el.lpar?
          stack << el
        elsif el.rpar?
          while !stack.empty? && !stack.last.lpar?
            res.push stack.pop
          end
          if stack.empty?
            throw BuildPostfixException #🥰🥰🥰 ошибка баланса скобок, не встречено открывающей скобки
          end
          stack.pop
          if !stack.empty? && stack.last.func?
            res.push(stack.pop)
          end
        end
      end
      until stack.empty?
        el = stack.last
        if el.lpar?
          throw BuildPostfixException # Нарашем баланс скобок
        end
        res.push(stack.pop)

      end
      res
    end

    def priority el
      if el.operation?
        case el.type
        when TokenType::PLUS, TokenType::MINUS
          1
        when TokenType::MULTIPLY, TokenType::DIVIDE
          2
        when TokenType::POWER
          3
        end
      else
        -1
      end
    end
  end
end
