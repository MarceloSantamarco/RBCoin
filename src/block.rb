require 'digest'
require 'json'

class Block

    attr_accessor :hash, :nonce, :id, :difficulty

    def initialize(created_at, data, previous_hash, previous_id, difficulty)
        @difficulty = difficulty
        @id = previous_id+1
        @nonce = 1
        @created_at = created_at
        @data = data
        @previous_hash = previous_hash
        @hash = create_hash()
    end

    def create_hash
        payload = {
            id: @id,
            nonce: @nonce,
            created_at: @created_at,
            data: @data,
            previous_hash: @previous_hash,
        }
        hasher = Digest::SHA256.digest(payload.to_json)
        Digest::SHA256.hexdigest(hasher)
    end

end