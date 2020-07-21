require 'sinatra'
require 'json'
require 'jwt'
require 'pry'

require_relative '../src/blockchain'
require_relative '../src/address'

blockchain = BlockChain.new
blocks = []

get '/' do
  blockchain.inspect.to_json
end

post '/blockchain/mine' do
  params = JSON.parse(request.body.read)
  user = JWT.decode(params["address"], File.read('password.txt'), true, algorithm: 'HS256')[0]
  block = if params["block_id"] == "1"
            blockchain.genesis
          else
            blocks.filter{|block| block.id == params["block_id"]}
          end
  blockchain.mine(block, user)
  blocks << block
  block.inspect.to_json
end

post '/address/new' do
  user = Address.new
  hash = {
    public_key: user.public_key,
    balance: user.balance
  }
  address = {
    address: JWT.encode(hash, File.read('password.txt'))
  }
  address.to_json
end

get '/transaction' do
  txs = blockchain.chain.map(&:data)
  txs << blockchain.pool
  hash = {transaction: []}
  txs.flatten.each do |tx|
    hash[:transaction] << {
      id: tx.id,
      sender: tx.sender.is_a?(String) ? tx.sender : tx.sender.public_key,
      amount: tx.amount,
      receiver: tx.receiver,
      signature: tx.signature.nil? ? nil : tx.signature
    }
  end
  hash.to_json
end

post '/transaction/new' do
  params = JSON.parse(request.body.read)
  sender = JWT.decode(params["sender"], File.read('1password.txt'), true, algorithm: 'HS256')[0]
  receiver = JWT.decode(params["receiver"], File.read('2password.txt'), true, algorithm: 'HS256')[0]
  amount = params["amount"]
  blockchain.new_transaction(sender, amount, receiver)
end