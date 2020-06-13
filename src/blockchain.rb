require_relative './block'
require_relative './transaction'

class BlockChain

    attr_accessor :chain

    def initialize
        @chain = []
        create_genesis_block()
    end

    def create_genesis_block
        block = Block.new(Time.now, {}, "0000", 0, 1)
        block.mine
        @chain << block
    end

    def new_block(data)
        block = Block.new(Time.now, data, @chain.last.hash, @chain.last.index, [3, 4, 5].sample)
        block.mine
        @chain << block
    end

    def new_transaction(sender, amount, receiver)
        transaction = Transaction.new(sender, amount, receiver)
        new_block(transaction)
    end

end