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

      recurDiff(ast)
      pp ast
    end

    private
    def recurDiff(root)
      pp root.value
      case root
      when Netherite::BinOpNode
        handleBinOp(root)
      end
    end

    def handleBinOp(node)
      case node.token.type
      when Netherite::TokenType::PLUS
        handleNodeAfterPlus(node.left)
        handleNodeAfterPlus(node.right)
      end
    end

    def handleNodeAfterPlus(node)
      case node
      when Netherite::NumberNode
        node.value = 0
      when Netherite::VarNode
        if node.value != @var
          if node.parent.left == node
            node.parent.left = Netherite::NumberNode.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 0))
            node.parent.left.parent = node.parent
          elsif node.parent.right == node
            node.parent.right = Netherite::NumberNode.new(Netherite::Token.new(Netherite::TokenType::NUMBER, 0))
            node.parent.right.parent = node.parent
          end
        end
      end
    end
  end
end
