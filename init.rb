require_relative './src/blockchain'
require_relative './src/address'
require 'securerandom'

users = []
2.times do
    users << {
        address: Address.new()
    }
end

b = BlockChain.new()

b.new_transaction(users[0], 10, users[1])
b.new_transaction(users[1], 5, users[0])

b.new_block(b.pool)

puts b.chain.last.inspect