require_relative './block'
require_relative './transaction'

class BlockChain

    attr_accessor :chain, :pool, :genesis

    def initialize
        @chain = []
        @pool = []
        @genesis = create_genesis_block()
    end

    def create_genesis_block
        block = Block.new(Time.now, @pool, "0000", 0, 1)
        block
    end

    def new_block()
        block = Block.new(Time.now, @pool, @chain.last.hash, @chain.last.id, @chain.last.difficulty+1)
        block
    end

    def mine(block, address)
        difficulty = block.difficulty-1
        loop do
            hash = block.create_hash
            hash_difficulty_slice = hash[0..difficulty].chars.uniq
            if hash_difficulty_slice.first == '0' && hash_difficulty_slice.length == 1
                block.hash = hash
                @chain << block
                @pool = []
                new_transaction("coinbase##{block.id}", 100, address)
                puts "Bloco #{block.id}, com dificuldade #{block.difficulty} foi minerado com nonce #{block.nonce} e hash #{block.hash}"
                break
            else
                block.nonce+=1
                next
            end
        end
        true
    end

    def new_transaction(sender, amount, receiver)
        transaction = Transaction.new(sender, amount, receiver)

        return false if transaction.sender.nil?

        if transaction.check_signature()
            transaction.create_id(self)
            @pool << transaction
            return true
        else
            return false
        end
    end

end