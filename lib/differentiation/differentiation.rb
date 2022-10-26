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
      fixUnarNode(ast)
      ast.printAST
      ast.toString
    end

    private
    def recurDiff(root)
      case root.nodeType
      when Netherite::NodeType::BINNODE
        handleBinOp(root)
      when Netherite::NodeType::UNARNODE
        recurDiff(root.left)
      when Netherite::NodeType::VAR
        root = root.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, root.value != @var ? 0 : 1))
      when Netherite::NodeType::FUNCNODE
        handleFunctions(root)
      when Netherite::NodeType::FUNCBINNODE
        handleBinFunctions(root)
      end
    end


    def handleBinOp(node)
      if !searchDiffVar(node) && node.parent.nil?
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
        if searchDiffVar(node.left) && searchDiffVar(node.right)
          handleMultilpy(node)
        else
          handleNodeAfterMultiply(node.left)
          handleNodeAfterMultiply(node.right)
        end
        tryToDeleteMult(node) if node.value == "*"
        tryToDeleteMult(node.right) if !node.right.nil? && node.right.value == "*"
        tryToDeleteMult(node.left) if !node.left.nil? && node.left.value == "*"
      when Netherite::TokenType::POWER
        handleNodeAfterPower(node.right)
        tryToDeletePower(node)
        tryToDeleteMult(node) if node.value == "*"
      when Netherite::TokenType::DIVIDE
        if !searchDiffVar(node.right)
          recurDiff(node.left)
        else
          handleNodeAfterDivide(node)
        end
      end
    end

    def fixUnarNode(node)
      nodes = Array.new
      searchAllUnarNodes(node, nodes)
      nodes.each do |n|
        n.right = n.left
        n.left.parent = nil
        n.left = nil
      end
    end

    def searchAllUnarNodes(node, nodes)
      return if node.nil?
      if node.token.type == Netherite::TokenType::UNMINUS || defined?(node.token.type.type) && node.token.value == "-"
        nodes.push(node)
      end
      searchAllUnarNodes(node.left, nodes) || searchAllUnarNodes(node.right, nodes)
    end

    def handleNodeAfterPlus(node)
      case node.nodeType
      when Netherite::NodeType::NUMBER
        node.value = 0
      when Netherite::NodeType::VAR
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, node.value != @var ? 0 : 1))
      when Netherite::NodeType::BINNODE
        handleBinOp(node)
      when Netherite::NodeType::UNARNODE
        handleNodeAfterPlus(node.left)
      end
    end


    def handleNodeAfterMultiply(node)
      case node.nodeType
      when Netherite::NodeType::VAR
        if node.value == @var
          node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, 1))
        end
      when Netherite::NodeType::BINNODE
        handleBinOp(node)
      when Netherite::NodeType::UNARNODE
        handleNodeAfterMultiply(node.left)
      end
    end

    def handleMultilpy(node)
      udx = Marshal.load(Marshal.dump(node.left))  #u'(x)
      vdx = Marshal.load(Marshal.dump(node.right)) #v'(x)
      recurDiff(udx)
      recurDiff(vdx)

      u = node.left
      v = node.right
      node.replace_this_node(Netherite::Token.new(Netherite::TokenType::PLUS, "+"))
      node.left = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::MULTIPLY, "*"))
      node.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::MULTIPLY, "*"))

      node.left.parent = node
      node.right.parent = node
      node.left.left = udx
      udx.parent = node.left
      node.left.right = v
      v.parent = node.left

      node.right.left = u
      u.parent = node.right
      node.right.right = vdx
      vdx.parent = node.right
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
      tryToDeleteMult(node.left.left)
      tryToDeleteMult(node.left.right)
      tryToDeleteMinus(node.left)
    end

    def handleBinFunctions(node)
      if (node.right.nodeType != Netherite::NodeType::VAR)
        copy_right = Marshal.load(Marshal.dump(node.right))

        if node.parent != nil
          new_root = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::MULTIPLY, "*"))
          new_root.left = copy_right
          copy_right.parent = new_root
          if node.parent.left == node
            node.parent.left = new_root
          else
            node.parent.right = new_root
          end
          new_root.right = node
          node.parent = new_root
          node = new_root
        else
          copy_node = Marshal.load(Marshal.dump(node))
          node.set_token! Netherite::Token.new(Netherite::TokenType::MULTIPLY, "*")
          node.nodeType = Netherite::NodeType::BINNODE
          node.left = copy_right
          copy_right.parent = node
          node.right = copy_node
          copy_node.parent = node
        end

        recurDiff(node.left)
      end

      parent = nil
      if (node.token.type == Netherite::TokenType::MULTIPLY)
        parent = node
        node = node.right
      end

      case node.token.type
      when Netherite::TokenType::LOG
        handleLog(node)
      end

      if (parent != nil)
        tryToDeleteMult(parent)
      end
    end

    def handleLog(node)
      copy_node = Marshal.load(Marshal.dump(node))
      node.set_token! Netherite::Token.new(Netherite::TokenType::DIVIDE, "/")
      node.nodeType = Netherite::NodeType::BINNODE
      node.left = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 1))
      node.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::MULTIPLY, "*"))
      node.right.left = copy_node.right
      copy_node.right.parent = node.right.left
      node.right.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::LN, "ln"))
      node.right.right.left = copy_node.left
      copy_node.left.parent = node.right.right.left
    end
    def handleFunctions(node)
      if (node.left.nodeType != Netherite::NodeType::VAR)
        copy_left = Marshal.load(Marshal.dump(node.left))

        if node.parent != nil
          new_root = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::MULTIPLY, "*"))
          new_root.left = copy_left
          copy_left.parent = new_root
          if node.parent.left == node
            node.parent.left = new_root
          else
            node.parent.right = new_root
          end
          node = new_root
        else
          copy_node = Marshal.load(Marshal.dump(node))
          node.set_token! Netherite::Token.new(Netherite::TokenType::MULTIPLY, "*")
          node.nodeType = Netherite::NodeType::BINNODE
          node.left = copy_left
          copy_left.parent = node
          node.right = copy_node
          copy_node.parent = node
        end

        recurDiff(node.left)
      end

      parent = nil
      if (node.token.type == Netherite::TokenType::MULTIPLY)
        parent = node
        node = node.right
      end

      case node.token.type
      when Netherite::TokenType::SIN
        handleSin(node)
      when Netherite::TokenType::COS
        handleCos(node)
      when Netherite::TokenType::TG
        handleTg(node)
      when Netherite::TokenType::CTG
        handleCtg(node)
      when Netherite::TokenType::LN
        handleLn(node)
      end

      if (parent != nil)
        tryToDeleteMult(parent)
      end
    end

    def handleSin(node)
      node.set_token! Netherite::Token.new(Netherite::TokenType::COS, "cos")
    end

    def handleCos(node)
      copy_node = Marshal.load(Marshal.dump(node))
      node.set_token! Netherite::Token.new(Netherite::TokenType::UNMINUS, "-")
      node.nodeType = Netherite::NodeType::UNARNODE
      copy_node.set_token! Netherite::Token.new(Netherite::TokenType::SIN, "sin")
      node.left = copy_node
      node.right = nil
      copy_node.parent = node
    end

    def handleTg(node)
      copy_node = Marshal.load(Marshal.dump(node.left))
      node.set_token! Netherite::Token.new(Netherite::TokenType::DIVIDE, "/")
      node.nodeType = Netherite::NodeType::BINNODE
      node.left = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 1))
      node.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::POWER, "^"))
      node.right.left = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 2))
      node.right.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::COS, "cos"))
      node.right.right.left = copy_node
      copy_node.parent = node.right.right
    end

    def handleCtg(node)
      copy_node = Marshal.load(Marshal.dump(node.left))
      node.set_token! Netherite::Token.new(Netherite::TokenType::UNMINUS, "-")
      node.nodeType = Netherite::NodeType::UNARNODE
      node.left = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::DIVIDE, "/"))
      node.left.left = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 1))
      node.left.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::POWER, "^"))
      node.left.right.left = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 2))
      node.left.right.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::COS, "cos"))
      node.left.right.right.left = copy_node
      copy_node.parent = node.left.right.right
    end

    def handleLn(node)
      copy_node = Marshal.load(Marshal.dump(node.left))
      node.set_token! Netherite::Token.new(Netherite::TokenType::DIVIDE, "/")
      node.nodeType = Netherite::NodeType::BINNODE
      node.left = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 1))
      node.right = copy_node
      copy_node.parent = node.right
    end

    def handleNodeAfterPower(node)
      case node.nodeType
      when Netherite::NodeType::NUMBER
        if node.parent.value == "-"
          node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, node.value + 1))
          addValueOfPowSimple(node.parent)
        else
          node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, node.value - 1))
          addValueOfPowSimple(node)
        end
      when Netherite::NodeType::UNARNODE
        handleNodeAfterPower(node.left)
      when Netherite::NodeType::VAR
        node.left = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::VAR, node.value))
        node.left.parent = node
        node.right = Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 1))
        node.right.parent = node
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
              tryToDeletePlus(node)
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
        parent = node.parent
        if node == node.parent.right
          right = true
        end
        node.replace_node_with_node(Netherite::Node.new(Netherite::Token.new(Netherite::TokenType::NUMBER, new_value)))
        node.parent = parent
        if right
          node.parent.right = node
        else
          node.parent.left = node
        end
      elsif node.right.value == 1
        node.left.parent = node.parent
        if !node.parent.nil?
          if node == node.parent.left
            node.parent.left = node.left
          else
            node.parent.right = node.left
          end
          node.parent = nil
        else
          node.replace_node_with_node(node.left)
        end
      elsif node.left.value == 1
        node.right.parent = node.parent
        if !node.parent.nil?
          if node == node.parent.left
            node.parent.left = node.right
          else
            node.parent.right = node.right
          end
        else
          node.replace_node_with_node(node.right)
        end
      elsif node.right.value == 0 || node.left.value == 0
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, 0))
        node.left = nil
        node.right = nil
      end
      if !node.parent.nil? && !node.parent.left.nil? && !node.left.nil? && node.parent.left.nodeType == Netherite::NodeType::NUMBER && node.left.nodeType == Netherite::NodeType::NUMBER
        if node.parent.value == "*" && node.value == "*"
          temp_value = node.parent.left.value
          node = node.parent
          node.right.right.parent = node
          node.right.left.parent = node
          node.left = node.right.left
          node.right = node.right.right
          node.left.value = temp_value * node.left.value
        end
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

    def tryToDeletePower(node)
      if node.left.nodeType == Netherite::NodeType::NUMBER && node.right.nodeType == Netherite::NodeType::NUMBER
        new_value = node.left.value** node.right.value
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, new_value))
      elsif node.right.value == 1
        node.replace_node_with_node(node.left)
      end
    end
  end
end
