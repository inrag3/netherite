# frozen_string_literal: true

# Module for solving different types of equations
module Equation
  class << self
    def discriminant(a, b, c)
      b**2 - 4 * a * c
    end

    def quadratic(equation)

      lexer = Netherite::Lexer.new(equation)
      tokens = lexer.normalize_tokens(lexer.fix_unar_operations(lexer.tokens))
      postfix = Netherite::PostfixBuilder.new(tokens)
      ast = Netherite::ASTBuilder.new(postfix.postfix).build
      ast.printAST
      a, b, c = find_coefs(ast, a, b, c)

      d = discriminant(a, b, c)
      if a != 0
        if d < 0
          puts "has no real roots"
        elsif d == 0
          puts "x = " + (-b/(2*a)).to_s
        else
          puts "x_1 = " + ((-b + Math.sqrt(d))/(2*a)).to_s + "; x_2 = " + ((-b - Math.sqrt(d))/(2*a)).to_s
        end
      else
        if b != 0
          puts "x = " + (-c/b).to_s
        else
          puts "invalid input"
        end
      end
    end

    def biquadratic(equation)
      puts equation
      equation = equation.sub("^2","")
      equation = equation.sub("^4","^2")

      lexer = Netherite::Lexer.new(equation)
      tokens = lexer.normalize_tokens(lexer.fix_unar_operations(lexer.tokens))
      postfix = Netherite::PostfixBuilder.new(tokens)
      ast = Netherite::ASTBuilder.new(postfix.postfix).build
      ast.toString

      a, b, c = find_coefs(ast, a, b, c)

      result = Array.new
      d = discriminant(a, b, c)
      puts "\n"
      if a != 0
        if d < 0
          puts "has no real roots"
        elsif d == 0
          x1 = Math.sqrt(-b/(2*a))
          x2 = -Math.sqrt(-b/(2*a))
          result.push(x1,x2)
          puts "x_1 = " + x1.to_s + "; x_2 = " + x2.to_s
        else
          t1 = (-b + Math.sqrt(d))/(2*a)
          t2 = (-b - Math.sqrt(d))/(2*a)
          if t1 >= 0
            x1 = Math.sqrt(t1)
            x2 = -Math.sqrt(t1)
            puts "x_1_1 = " + x1.to_s + "; x_1_2 = " + x2.to_s
            result.push(x1,x2)
          end
          if t2 >= 0
            x1 = Math.sqrt(t2)
            x2 = -Math.sqrt(t2)
            puts "x_2_1 = " + x1.to_s + "; x_2_2 = " + x2.to_s
            result.push(x1,x2)
          end
        end
      else
        if b != 0
          t = -c/b
          if t >= 0
            x1 = Math.sqrt(t)
            x2 = -Math.sqrt(t)
            puts "x_1 = " + x1.to_s + "; x_2 = " + x2.to_s
            result.push(x1,x2)
          elsif
            puts "has no real roots"
          end
        else
          puts "invalid input"
        end
      end

    end

    private
    def find_coefs(node, a, b, c)
      a = 0
      b = 0
      c = 0
      nodes = Array.new
      search_all_x(node, nodes)
      nodes.each do |n|
        if !n.parent.nil?
          case n.parent.value
          when "^"
            if n.parent.parent.value == "*"
              if n.parent.parent.left.token.type == Netherite::TokenType::NUMBER
                a = n.parent.parent.left.value
              else a = -n.parent.parent.left.left.value
              end
            else
              a = 1
            end
          when "*"
            if n.parent.left.token.type == Netherite::TokenType::NUMBER
              if !n.parent.parent.nil? && !n.parent.parent.value == "-"
                b = n.parent.left.value
              elsif n.parent.left.value == "-"
                b = -n.parent.left.left.value
              else b = -n.parent.left.value
              end
            end
          end
        else b = 1
        end
      end

      check = node.right
      while (check != nil)
        node = node.right
        check = check.right
      end
      if !node.nil? && node.token.type == Netherite::TokenType::NUMBER
        if node.parent.value == "-"
          c = -node.value
        else c = node.value
        end
      end
      return [a,b,c]
    end

    def search_all_x(node, nodes)
      return if node.nil?
      nodes.push(node) if node.nodeType == Netherite::NodeType::VAR
      search_all_x(node.left, nodes) || search_all_x(node.right, nodes)
    end
  end
end

