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

      ast.print
      puts "\n\n\n"
      recurDiff(ast)
      ast.print
    end

    private
    def recurDiff(root)
      case root.nodeType
      when Netherite::NodeType::BINNODE
        handleBinOp(root)
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
      when Netherite::TokenType::MULTIPLY
        handleNodeAfterMultiply(node.left)
        handleNodeAfterMultiply(node.right)
        tryToDeleteMult(node)
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

    def searchDiffVar(node)
      return false if node.nil?
      return true if node.nodeType == Netherite::NodeType::VAR && node.value == @var

      return searchDiffVar(node.left) || searchDiffVar(node.right)
    end

    def tryToDeleteMult(node)
      if node.left.nodeType == Netherite::NodeType::NUMBER && node.right.nodeType == Netherite::NodeType::NUMBER
        new_value = node.left.value.to_i * node.right.value.to_i
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, new_value))
      end
    end
    def tryToDeletePlus(node)
      if node.left.nodeType == Netherite::NodeType::NUMBER && node.right.nodeType == Netherite::NodeType::NUMBER
        new_value = node.left.value.to_i + node.right.value.to_i
        node.replace_this_node(Netherite::Token.new(Netherite::TokenType::NUMBER, new_value))
      end
    end
  end
end
