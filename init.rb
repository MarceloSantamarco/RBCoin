require_relative './src/blockchain'
require_relative './src/address'
require 'json'

users = []
2.times do
    users << Address.new()
end

blockchain = BlockChain.new()
puts users[1].balance
puts users[0].balance

blockchain.new_transaction(users[1], 10, users[0])
puts users[1].balance
puts users[0].balance

blockchain.mine(blockchain.genesis, users[1])
puts users[1].balance
puts users[0].balance

blockchain.new_transaction(users[1], 10, users[0])
puts users[1].balance
puts users[0].balance

block = blockchain.new_block()

blockchain.mine(block, users[1])
puts users[1].balance
puts users[0].balance

blockchain.new_transaction(users[1], 40, users[0])
puts users[1].balance
puts users[0].balance

block = blockchain.new_block()

blockchain.mine(block, users[0])
puts users[1].balance
puts users[0].balance

puts "\n#{blockchain.chain.last.inspect.to_json}\n"