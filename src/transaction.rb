require 'openssl'
require 'json'

class Transaction
    attr_accessor :sender, :amount, :receiver, :id, :signature

    def initialize(sender, amount, receiver)
        if !sender.is_a?(String) && amount.to_i > sender['balance'].to_i
            puts "ValueError - insufficient funds"
            return nil
        end
        @id = nil,
        @sender = sender
        @amount = amount
        @receiver = receiver
        @signature = generate_signature()
    end

    def create_id(blockchain)
        txs_previous_block = blockchain.chain.last.data
        txs_current_pool = blockchain.pool
        tx_id = txs_current_pool.empty? ? (txs_previous_block.empty? ? 1 : txs_previous_block.last.id+1) : txs_current_pool.last.id+1
        @id = tx_id
    end

    def check_signature
        begin
            return true if @sender.include?('coinbase')
        rescue
            pub_key = OpenSSL::PKey::RSA.new(@sender.public_key)
            signature = @signature
            data = {sender: @sender, amount: @amount, receiver: @receiver}
            valid = pub_key.verify(OpenSSL::Digest::SHA256.new(), signature, data.to_json)
            if valid then puts "TX of #{@sender} verifyed!" else puts "TX of #{@sender} invalid!" end
        end
        valid
    end

    private

    def generate_signature
        begin
            return nil if @sender.include?('coinbase')
        rescue
            data = {sender: @sender, amount: @amount, receiver: @receiver}
            pkey = OpenSSL::PKey::RSA.new(File.read('private_key.pem'), File.read('password.txt'))
        end
        pkey.sign(OpenSSL::Digest::SHA256.new(), data.to_json)
    end

end