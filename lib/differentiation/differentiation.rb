require "./lib/netherite/ast_builder"
require "./lib/netherite/lexer"
require "./lib/netherite/postfix_builder"

module Differentiation
  class << self
    def diff(equation, var)
      lexer = Netherite::Lexer.new(equation)
      tokens = lexer.normalize_tokens(lexer.fix_unar_operations(lexer.tokens))
      postfix = Netherite::PostfixBuilder.new(tokens)
      ast = Netherite::ASTBuilder.new(postfix.postfix).build
      pp ast

      @var = var
      @indent = 0

      ast.printAST
      puts "\n\n\n"
      recurDiff(ast)
      ast.printAST
      ast.toString
    end

    private
    def recurDiff(root)
      case root.nodeType
      when Netherite::NodeType::BINNODE
        handleBinOp(root)
      when Netherite::NodeType::VAR
        root = root.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, root.value != @var ? 0 : 1))
      end
    end

    def handleBinOp(node)
      unless searchDiffVar(node)
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, 0))
      end
      case node.token.type
      when Netherite::TokenType::PLUS
        handleNodeAfterPlus(node.left)
        handleNodeAfterPlus(node.right)
        tryToDeletePlus(node)
      when Netherite::TokenType::MINUS
        handleNodeAfterPlus(node.left)
        handleNodeAfterPlus(node.right)
        tryToDeleteMinus(node)
      when Netherite::TokenType::MULTIPLY
        handleNodeAfterMultiply(node.left)
        handleNodeAfterMultiply(node.right)
        tryToDeleteMult(node)
      when Netherite::TokenType::POWER
        handleNodeAfterPower(node.right)
        #tryToDeletePower(node)
      when Netherite::TokenType::DIVIDE
        if !searchDiffVar(node.right)
          recurDiff(node.left)
        else
          handleNodeAfterDivide(node)
        end
      end
    end

    def handleNodeAfterPlus(node)
      case node.nodeType
      when Netherite::NodeType::NUMBER
        node.value = 0
      when Netherite::NodeType::VAR
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, node.value != @var ? 0 : 1))
      else
        recurDiff(node)
      end
    end

    def handleNodeAfterMultiply(node)
      case node.nodeType
      when Netherite::NodeType::VAR
        if node.value == @var
          node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, 1))
        end
        end
    end

    def handleNodeAfterDivide(node)
      udx = Marshal.load(Marshal.dump(node.left))
      vdx = Marshal.load(Marshal.dump(node.right))
      udx.parent = nil #u'(x)
      vdx.parent = nil #v'(x)
      recurDiff(udx)
      recurDiff(vdx)
      v = Marshal.load(Marshal.dump(node.right)) #v; node.left = u
      temp_pow = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::POWER, "^"))
      node.right.parent = temp_pow
      temp_pow.left = node.right
      temp_pow.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 2))
      node.right = temp_pow

      temp_minus = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::MINUS, "-"))
      temp_minus.parent = node
      temp_minus.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::MULTIPLY, "*"))
      temp_minus.right.parent = temp_minus
      temp_minus.right.right = node.left
      node.left.parent = temp_minus.right
      node.left = temp_minus
      temp_minus.right.left = vdx
      vdx.parent = temp_minus.right

      temp_minus.left = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::MULTIPLY, "*"))
      temp_minus.left.parent = temp_minus
      temp_minus.left.left = udx
      udx.parent = temp_minus.left
      temp_minus.left.right = v
      v.parent = temp_minus.left
    end

    def handleNodeAfterPower(node)
      case node.nodeType
      when Netherite::NodeType::NUMBER
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, node.value - 1))
        addValueOfPowSimple(node)
      when Netherite::NodeType::VAR
        node.left = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::VAR, node.value))
        node.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 1))
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::MINUS, "-"))
        addValueOfPowSimple(node)
      when Netherite::NodeType::BINNODE
        case node.token.type
        when Netherite::TokenType::DIVIDE
          addValueOfPowComplex(node)
          node.parent.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::MINUS, "-"))
          node.parent.right.left = node
          node.parent.right.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 1))
        when Netherite::TokenType::MULTIPLY
          addValueOfPowComplex(node)
          node.parent.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::MINUS, "-"))
          node.parent.right.left = node
          node.parent.right.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 1))
        when Netherite::TokenType::MINUS
          addValueOfPowComplex(node)
          if node.right.token.type == Netherite::TokenType::NUMBER
            node.right.replace_this_node(Netherite::Token.new(Netherite::TokenType::VAR, node.right.value + 1))
          else
            node.parent.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::MINUS, "-"))
            node.parent.right.left = node
            node.parent.right.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 1))
          end
          when Netherite::TokenType::PLUS
            addValueOfPowComplex(node)
            if node.right.token.type == Netherite::TokenType::NUMBER
              if node.right.value - 1 >= 0
               node.right.replace_this_node(Netherite::Token.new(Netherite::TokenType::VAR, node.right.value - 1))
              else
               node.right.replace_this_node(Netherite::Token.new(Netherite::TokenType::VAR, -(node.right.value - 1)))
               node.replace_this_node(Netherite::Token.new(Netherite::TokenType::MINUS, "-"))
              end
            else
              node.parent.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::MINUS, "-"))
              node.parent.right.left = node
              node.parent.right.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 1))
            end
        end
      end
    end

    def addValueOfPowSimple(node)
      temp_node = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::MULTIPLY, "*"))
      temp_node.right = node.parent.left
      temp_node.left = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, node.value))
      node.parent.left.parent = temp_node
      node.parent.left = temp_node
    end

    def addValueOfPowComplex(node)
      temp_node = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::MULTIPLY, "*"))
      pow_node = node.clone
      pow_node.parent = temp_node
      temp_node.right = node.parent.left
      temp_node.left = pow_node
      node.parent.left.parent = temp_node
      node.parent.left = temp_node
      temp_node.parent = node.parent
    end

    def searchDiffVar(node)
      return false if node.nil?
      return true if node.nodeType == Netherite::NodeType::VAR && node.value == @var

      return searchDiffVar(node.left) || searchDiffVar(node.right)
    end

    def tryToDeleteMult(node)
      if node.left.nodeType == Netherite::NodeType::NUMBER && node.right.nodeType == Netherite::NodeType::NUMBER
        new_value = node.left.value * node.right.value
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, new_value))
      elsif node.left.nodeType == Netherite::NodeType::VAR && node.right.value == 1
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::VAR, node.left.value))
      elsif node.right.nodeType == Netherite::NodeType::VAR && node.left.value == 1
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::VAR, node.right.value))
      elsif node.right.value == 0 || node.left.value == 0
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, 0))
      end
    end
    def tryToDeletePlus(node)
      if node.left.nodeType == Netherite::NodeType::NUMBER && node.right.nodeType == Netherite::NodeType::NUMBER
        new_value = node.left.value + node.right.value
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, new_value))
      elsif node.left.nodeType == Netherite::NodeType::VAR && node.right.value == 0
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::VAR, node.left.value))
      elsif node.right.nodeType == Netherite::NodeType::VAR && node.left.value == 0
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::VAR, -node.right.value))
      end
    end

    def tryToDeleteMinus(node)
      if node.left.nodeType == Netherite::NodeType::NUMBER && node.right.nodeType == Netherite::NodeType::NUMBER
        new_value = node.left.value - node.right.value
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, new_value))
      elsif node.left.nodeType == Netherite::NodeType::VAR && node.right.value == 0
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::VAR, node.left.value))
      elsif node.right.nodeType == Netherite::NodeType::VAR && node.left.value == 0
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::VAR, node.right.value))
      end
    end

    #todo очень сильно подумать
    def tryToDeletePower(node)
      if node.left.nodeType == Netherite::NodeType::NUMBER && node.right.nodeType == Netherite::NodeType::NUMBER
        new_value = node.left.value** node.right.value
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, new_value))
      elsif node.right.value == 1
        if node.parent.nil?
          node = node.left
          node.parent.left = nil
          node.parent.right = nil
          node.parent = nil
        else
          node = node.left
          node.parent = node.parent.parent
          node.parent.left = node
        end
      end
    end
  end
end