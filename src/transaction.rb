require 'openssl'
require 'json'

class Transaction
    attr_accessor :sender, :amount, :receiver, :id

    def initialize(sender, amount, receiver)
        @id = nil,
        @sender = sender
        @amount = amount
        @receiver = receiver
        @signature = generate_signature()
    end

    def create_id(tx_id)
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