require 'sinatra'
require 'json'
require 'jwt'
require 'pry'

require_relative '../src/blockchain'
require_relative '../src/address'

blockchain = BlockChain.new
current_block = blockchain.genesis

File.open('secret_key.txt', 'w') do |f|
  f.write(SecureRandom.hex(60))
end

def serialize_block(block)
  hash = {
    id: block,
    difficulty: block.difficulty,
    nonce: block.nonce,
    created_at: block.created_at,
    data: block.data,
    previous_hash: block.previous_hash,
    hash: block.hash
  }
  hash
end

get '/' do
  blockchain.inspect.to_json
end

get '/block/available' do
  hash = serialize_block(current_block)
  hash.to_json
end

post '/blockchain/mine' do
  return if current_block.nil?
  params = {
    address: request['address'],
  }
  user = JWT.decode(params[:address], File.read('secret_key.txt'), true, algorithm: 'HS256')[0]
  block = current_block

  blockchain.mine(block, user)
  current_block = nil
  serialize_block(blockchain.chain.last).to_json
end

post '/address/new' do
  user = Address.new
  hash = {
    public_key: user.public_key,
    balance: user.balance
  }
  address = {
    address: JWT.encode(hash, File.read('secret_key.txt'))
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
      sender: tx.sender.is_a?(String) ? tx.sender : JWT.encode(tx.sender, File.read('secret_key.txt')),
      amount: tx.amount,
      receiver: JWT.encode(tx.receiver, File.read('secret_key.txt')),
      signature: tx.signature.nil? ? nil : tx.signature
    }
  end
  hash.to_json
end

post '/transaction/new' do
  params = {
    sender: request['sender'],
    amount: request['amount'],
    receiver: request['receiver']
  }
  sender = JWT.decode(params[:sender], File.read('secret_key.txt'), true, algorithm: 'HS256')[0]
  receiver = JWT.decode(params[:receiver], File.read('secret_key.txt'), true, algorithm: 'HS256')[0]
  amount = params[:amount]
  blockchain.new_transaction(sender, amount, receiver)
  current_block = blockchain.new_block() if blockchain.pool.map(&:amount).sum > 650
end