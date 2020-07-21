require 'openssl'
require 'securerandom'

class Address
    attr_accessor :public_key, :balance

    def initialize
        @public_key = generate_keys()
        @balance = 0
    end

    private

    def generate_keys
        password = SecureRandom.hex(10)

        generate_private_key(password)
        
        OpenSSL::PKey::RSA.new(File.read('private_key.pem'), password).public_key
    end

    def generate_private_key(password)
        rsa_key = OpenSSL::PKey::RSA.new(2048)
        cipher =  OpenSSL::Cipher::Cipher.new('des3')

        File.open("private_key.pem", "w") do |f|     
            f.write(rsa_key.to_pem(cipher, password))   
        end

        File.open("password.txt", "w") do |f|     
            f.write(password)   
        end
    end
end