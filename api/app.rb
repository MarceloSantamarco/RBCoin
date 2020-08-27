require 'sinatra'
require 'json'
require 'jwt'
require 'pry'

require_relative '../src/blockchain'
require_relative '../src/address'

blockchain = BlockChain.new
current_block = blockchain.genesis
$adresses = []

File.open('secret_key.txt', 'w') do |f|
  f.write(SecureRandom.hex(60))
end

def serialize_block(block)
  hash = {
    id: block.id,
    difficulty: block.difficulty,
    nonce: block.nonce,
    created_at: block.created_at,
    data: block.data,
    previous_hash: block.previous_hash,
    hash: block.hash
  }
  hash
end

def decode(encoded_address)
  address = JWT.decode(encoded_address, File.read('secret_key.txt'), true, algorithm: 'HS256')[0]
  address
end

def update_address(address, amount)
  index = $adresses.index{|h| h[:id] == address['id'].to_i}
  address = decode($adresses[index][:address])
  address['balance'] += amount.to_i
  $adresses[index][:address] = JWT.encode(address, File.read('secret_key.txt'))
end

def get_address(address)
  index = $adresses.index{|h| h[:id] == address['id'].to_i}
  $adresses[index][:address]
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
  user = decode(get_address(request['address']))
  block = current_block

  if blockchain.mine(block, user)
    update_address(request['address'], 100)
    current_block = nil
  end

  serialize_block(blockchain.chain.last).to_json
end

post '/address/new' do
  user = Address.new
  hash = {
    public_key: user.public_key,
    balance: user.balance
  }
  address = {
    id: $adresses.length+1,
    address: JWT.encode(hash, File.read('secret_key.txt'))
  }
  $adresses << address
  address.to_json
end

get '/transaction' do
  txs = blockchain.chain.map(&:data)
  txs << blockchain.pool
  hash = []
  txs.flatten.each do |tx|
    hash << {
      id: tx.id,
      sender: tx.sender.is_a?(String) ? tx.sender : JWT.encode(tx.sender, File.read('secret_key.txt')),
      amount: tx.amount,
      receiver: JWT.encode(tx.receiver, File.read('secret_key.txt'))
      # signature: tx.signature.nil? ? nil : tx.signature
    }
  end

  hash.to_json
end

post '/transaction/new' do
  params = {
    sender: get_address(request['sender']),
    amount: request['amount'],
    receiver: get_address(request['receiver'])
  }
  sender = decode(params[:sender])
  receiver = decode(params[:receiver])
  amount = params[:amount]

  if blockchain.new_transaction(sender, amount, receiver)
    update_address(request['sender'], -amount)
    update_address(request['receiver'], amount)
  end

  current_block = blockchain.new_block() if blockchain.pool.map(&:amount).map{|a| a.to_i}.sum > 650
end