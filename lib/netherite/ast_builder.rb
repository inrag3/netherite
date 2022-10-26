module Netherite

  class ASTBuilderException < RuntimeError; end

  class ASTBuilder

    def initialize(tokens)
      @tokens = tokens.reverse
    end

    def build
      if @tokens.empty?
        nil
      else
        res = nil
        @pos = 0
        res = create_node

        if @pos < @tokens.size
          throw ASTBuilderException "построение дерева окончено до окончания токенов" #todo стоит поменять класс ошибки на другой
        end
        res
      end
    end

    private

    def create_node
      if @tokens[@pos].func?
        create_func_node
      elsif @tokens[@pos].operation?
        if @tokens[@pos].unary_operation?
          create_unary_operation_node
        else
          create_bin_op_node
        end
      elsif @tokens[@pos].var_number?
        case @tokens[@pos].type
        when TokenType::NUMBER
          create_num_node
        when TokenType::VAR
          create_var_node
        else
          create_e_node
        end
      elsif @tokens[@pos].lpar? || @tokens[@pos].rpar? || @tokens[@pos].border?
        throw ASTBuilderException "встречена скобка или разделитель элементом при строительстве дерева"
      end
    end

    def create_var_node
      @pos += 1
      Node.new @tokens[@pos - 1]
    end

    def create_num_node
      @pos += 1
      Node.new @tokens[@pos - 1]
    end

    def create_bin_op_node
      temp = Node.new @tokens[@pos]
      @pos += 1
      throw ASTBuilderException "отсутствует аргумент у функции" if @pos >= @tokens.size
      temp.right = create_node
      temp.right.parent = temp
      throw ASTBuilderException "отсутствует аргумент у функции" if @pos >= @tokens.size
      temp.left = create_node
      temp.left.parent = temp
      temp

    end

    def create_unary_operation_node
      temp = Node.new(@tokens[@pos])
      @pos += 1
      throw ASTBuilderException "отсутствует аргумент у функции" if @pos >= @tokens.size
      temp.left = create_node
      temp.left.parent = temp
      temp
    end

    def create_func_node
      if @tokens[@pos].two_pos_func?
        temp = Node.new(@tokens[@pos])
        @pos += 1
        throw ASTBuilderException "отсутствует аргумент у функции" if @pos >= @tokens.size
        temp.right = create_node
        temp.right.parent = temp
        throw ASTBuilderException "отсутствует аргумент у функции" if @pos >= @tokens.size
        temp.left = create_node
        temp.left.parent = temp

      else
        temp = Node.new(@tokens[@pos])
        @pos += 1
        throw ASTBuilderException "отсутствует аргумент у функции" if @pos >= @tokens.size
        temp.left = create_node
        temp.left.parent = temp

      end
      temp
    end

    def create_e_node
      @pos += 1
      Node.new @tokens[@pos - 1]
    end

  end

  class Node
    attr_accessor :parent, :value, :token, :nodeType, :left, :right

    def initialize(token, parent = nil)
      @token = token
      @value = token.value
      @parent = parent
      @left = nil
      @right = nil
      @indent = 0
      set_token_type! token
    end

    def set_token!(token)
      @token = token
      @value = token.value
    end

    #private точно приватные свойства?

    def set_token_type!(token)
      if token.func?
        if token.type == TokenType::LOG
          @nodeType = NodeType::FUNCBINNODE
        else
          @nodeType = NodeType::FUNCNODE
        end

      elsif token.operation?
        if token.unary_operation?
          @nodeType = NodeType::UNARNODE
        else
          @nodeType = NodeType::BINNODE
        end
      elsif token.var_number?
        case token.type
        when TokenType::NUMBER
          @nodeType = NodeType::NUMBER
        when TokenType::VAR
          @nodeType = NodeType::VAR
        else
          @nodeType = NodeType::E

        end
      end
    end

    #TODO: по-моему, типы ноды не меняются нигде
    def replace_this_node(token)
      temp = Node.new token
      unless parent.nil?
        if parent.left == self
          parent.left = temp
        else
          parent.right = temp
        end
        temp.parent = @parent
      else
        set_token!(token)
        set_token_type!(token)
        @left = nil
        @right = nil
      end
      if temp.nodeType == NodeType::UNARNODE || temp.nodeType == NodeType::UNARNODE || temp.nodeType == NodeType::BINNODE || temp.nodeType == NodeType::FUNCBINNODE
        temp.left = @left
        unless left.nil?
          left.parent = temp
        end
        if temp.nodeType == NodeType::BINNODE || temp.nodeType == NodeType::FUNCBINNODE

          temp.right = @right
          unless right.nil?
            right.parent = temp
          end
        end
      end
      temp
    end

    def replace_node_with_node(node_new_value)
      self.set_token! (Netherite::Token.new(node_new_value.token, node_new_value.value))
      self.set_token_type! (Netherite::Token.new(node_new_value.token, node_new_value.value))
      self.left = node_new_value.left
      self.right = node_new_value.right
      if !node_new_value.right.nil?
        node_new_value.right.parent = self
      end
      if !node_new_value.left.nil?
        node_new_value.left.parent = self
      end
    end

    def printAST(node = self)
      puts "#{" " * (@indent)}----[#{node.value}]"
      @indent += 4
      if node.left != nil
        printAST(node.left)
      end
      if node.right != nil
        printAST(node.right)
      end
      @indent -= 4
    end

    #todo скобки
    def toString(node = self)
      if node.left != nil
        toString(node.left)
      end
      print node.value.to_s
      if node.right != nil
        toString(node.right)
      end
    end
  end

  module NodeType
    NUMBER = 0
    VAR = 1
    BINNODE = 2
    UNARNODE = 3
    FUNCNODE = 4
    FUNCBINNODE = 5
    E = 6
  end
end
