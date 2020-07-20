require 'digest'
require 'json'

class Block

    attr_accessor :id, :difficulty, :nonce, :data, :hash

    def initialize(created_at, data, previous_hash, previous_id, difficulty)
        @id = previous_id+1
        @difficulty = difficulty
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