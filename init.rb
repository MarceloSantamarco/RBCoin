require_relative './src/blockchain'
require_relative './src/address'
require 'json'

users = []
2.times do
    users << Address.new()
end

blockchain = BlockChain.new()
blockchain.mine(blockchain.genesis, users[1])

blockchain.new_transaction(users[1], 10, users[0])

block = blockchain.new_block()

blockchain.mine(block, users[1])

blockchain.new_transaction(users[1], 40, users[0])

block = blockchain.new_block()

blockchain.mine(block, users[0])

puts("\n#{blockchain.chain.last.inspect.to_json}\n")