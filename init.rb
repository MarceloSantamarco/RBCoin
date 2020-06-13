require_relative './src/blockchain'
require 'securerandom'

users = []
15.times do
    users << {
        address: SecureRandom.hex(10)
    }
end

b = BlockChain.new()

users.each_with_index do |user, i| 
    b.new_transaction(user, i+1, users.sample)
end

puts b.chain.inspect