require 'digest'
require 'json'

class Block

    attr_accessor :hash, :nonce, :index

    def initialize(created_at, data, previous_hash, previous_index)
        @index = previous_index+1
        @nonce = 1
        @created_at = created_at
        @data = data
        @previous_hash = previous_hash
        @hash = create_hash()
    end

    def create_hash
        payload = {
            index: @index,
            nonce: @nonce,
            created_at: @created_at,
            data: @data,
            previous_hash: @previous_hash,
        }
        hasher = Digest::SHA256.digest(payload.to_json)
        Digest::SHA256.hexdigest(hasher)
    end

    def mine
        loop do
            hash = self.create_hash
            if hash[0..3] == '0000'
                self.hash = hash
                break
            else
                self.nonce+=1
                next
            end
        end
        puts "Bloco #{self.index} minerado com nonce #{self.nonce} e hash #{self.hash}"
    end

end