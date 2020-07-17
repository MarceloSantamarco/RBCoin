require 'openssl'
require 'json'

class Transaction
    attr_accessor :sender, :amount, :receiver

    def initialize(sender, amount, receiver)
        @sender = sender
        @amount = amount
        @receiver = receiver
        @signature = generate_signature()
    end

    def check_signature
        pub_key = OpenSSL::PKey::RSA.new(@sender[:address].public_key)
        signature = @signature
        data = {sender: @sender, amount: @amount, receiver: @receiver}
        valid = pub_key.verify(OpenSSL::Digest::SHA256.new(), signature, data.to_json)
        if valid then puts "TX of #{@sender} verifyed!" else puts "TX of #{@sender} invalid!" end
        valid
    end

    private

    def generate_signature
        data = {sender: @sender, amount: @amount, receiver: @receiver}
        pkey = OpenSSL::PKey::RSA.new(File.read('private_key.pem'), File.read('password.txt'))
        pkey.sign(OpenSSL::Digest::SHA256.new(), data.to_json)
    end

end