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

    def trigonometric(equation)
      arr = equation.split()
      value = 0
      i = 1
      while i < arr.length
        if numeric?(arr[i])
          if arr[i-1] == "+"
            value -= arr[i].to_f
          elsif arr[i-1] == "-"
            value += arr[i].to_f
          elsif arr[i-1] == "="
            value += arr[i].to_f
          end
        end
        i+=1
      end

      if value > 1 || value < -1
        return "Has no roots"
      end

      case arr[0]
      when /^cos/
        puts "+-" + StandartCases(Math.acos(value)) + " + 2PI*n"
      when /^sin/
        puts "-(1)^n*" + StandartCases(Math.asin(value)) + " + PI*n"
      when /^tg/
        puts StandartCases(Math.atan(value)) + " + PI*n"
      when /^ctg/
        puts StandartCases(Math.atan(1.0/value)) + " + PI*n"
      end


    end

    def cubic(equation) #Метод Кардано
      a,b,c,d = find_cubic_coefs(equation)

      p = (c/a) - (b**2)/(3*a**2)
      q = (d/a) - (b*c)/(3*a**2) + (2*b**3)/(27*a**3)

      discriminant = (p/3)**3 + (q/2)**2
      if discriminant > 0
        u = cuberRoot(-q / 2.0 + Math.sqrt(discriminant))
        v = cuberRoot(-q / 2.0 - Math.sqrt(discriminant))
        puts x1_real = u + v - b / (a * 3.0)
        puts x2_real = -(u + v) / 2.0 - b / (a * 3.0)
        puts x2_imag = Math.sqrt(3.0) / 2.0 * (u - v)
        puts x3_real = x2_real
        puts x3_imag = -x2_imag
      elsif discriminant == 0
        u = cuberRoot(-q / 2.0)
        v = cuberRoot(-q / 2.0)
        puts x1_real = u + v - b /(a * 3.0)
        puts x2_real = -(u + v) / 2.0 - b / (a * 3.0)
      else
        phi = Math.acos(-q/2 * Math.sqrt((3/-p)**3))
        puts x1_real = 2*Math.sqrt(-p/3)*Math.cos(phi/3) - b / (a * 3.0)
        puts x2_real = 2*Math.sqrt(-p/3)*Math.cos(phi/3 + 2*Math::PI/3) - b / (a * 3.0)
        puts x3_real = 2*Math.sqrt(-p/3)*Math.cos(phi/3 - 2*Math::PI/3) - b / (a * 3.0)
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

        def numeric?(lookAhead)
          lookAhead.match?(/[[:digit:]]/)
        end

        def StandartCases(value)
          case value
          when Math::PI
            "PI"
          when Math::PI/2
            "PI/2"
          when Math::PI/3
            "PI/3"
          when Math::PI/4
            "PI/4"
          when Math::PI/6
            "PI/6"
          else value.to_s
          end
        end

        def find_cubic_coefs(equation)
          koefs = Array.new
          a = equation[/([[:digit:]]*)x\^3/, 1].to_f
          a_sign = equation[/([-]?)[[:digit:]]*x\^3/, 1]

          b = equation[/([[:digit:]]*)x\^2/, 1].to_f
          b_sign = equation[/([-+]?) ?[[:digit:]]*x\^2/, 1]

          c = equation[/([[:digit:]]*)x[$ +-]/, 1].to_f
          c_sign = equation[/([-+]?) ?[[:digit:]]*x[$ +-]/, 1]

          d = equation[/([[:digit:]]*)$/, 1].to_f
          d_sign = equation[/([-+]?) ?[[:digit:]]*$/, 1]

          a = a == 0 ? a_sign == "-" ? -1 : 1 : a_sign == "-" ? -a : a
          b = b == 0 ? b_sign == "-" ? -1 : 1 : b_sign == "-" ? -b : b
          c = c == 0 ? b_sign == "-" ? -1 : 1 : c_sign == "-" ? -c : c
          d = d_sign == "-" ? -d : d

          return[a,b,c,d]
        end
    def cuberRoot(number)
      number > 0 ? Math.exp(Math.log(number)/3.0) : -Math.exp(Math.log(-number)/3.0)
    end


      end
    end

