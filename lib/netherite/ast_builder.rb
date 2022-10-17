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
      VarNode.new @tokens[@pos - 1]
    end

    def create_num_node
      @pos += 1
      NumberNode.new @tokens[@pos - 1]
    end

    def create_bin_op_node
      temp = BinOpNode.new @tokens[@pos]
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
      temp = UnOpNode.new(@tokens[@pos])
      @pos += 1
      throw ASTBuilderException "отсутствует аргумент у функции" if @pos >= @tokens.size
      temp.right = create_node
      temp.right.parent = temp
      temp
    end

    def create_func_node
      if @tokens[@pos].two_pos_func?
        temp = FuncWith2ArgNode.new(@tokens[@pos])
        @pos += 1
        throw ASTBuilderException "отсутствует аргумент у функции" if @pos >= @tokens.size
        temp.second_argument = create_node
        temp.second_argument.parent = temp
        throw ASTBuilderException "отсутствует аргумент у функции" if @pos >= @tokens.size
        temp.argument = create_node
        temp.argument.parent = temp

      else
        temp = FuncNode.new(@tokens[@pos])
        @pos += 1
        throw ASTBuilderException "отсутствует аргумент у функции" if @pos >= @tokens.size
        temp.argument = create_node
        temp.argument.parent = temp

      end
      temp
    end

    def create_e_node
      @pos += 1
      ENode.new @tokens[@pos - 1]
    end

  end

  class Node
    attr_accessor :parent
    attr_reader :value, :token

    def initialize(token)
      @token = token
      @value = token.value
      @parent = nil
    end

    def set_token!(token)
      @token = token
      @value = token.value
    end
  end

  class BinOpNode < Node
    attr_accessor :left, :right

    def initialize(token, left: nil, right: nil)
      super token
      @left = left
      @right = right
    end

  end

  class UnOpNode < Node
    attr_accessor :right

    def initialize(token, right: nil)
      super token
      @right = right
    end

  end

  class VarNode < Node
    attr_accessor :name

    def initialize(token)
      super token
      @name = token.value
    end

  end

  class NumberNode < Node
    attr_accessor :value

    def initialize(token)
      super token
      @value = Float(token.value)
    end

  end

  class FuncNode < Node
    attr_accessor :argument

    def initialize(token)
      super token
      @argument = nil
    end
  end

  class FuncWith2ArgNode < FuncNode
    attr_accessor :second_argument

    def initialize(token)
      super token
      @second_argument = nil
    end
  end

  class ENode < Node
  end
end
