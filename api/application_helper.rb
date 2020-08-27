module ApplicationHelper

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

    def get_address(address, adresses)
        index = adresses.index{|h| h[:id] == address['id'].to_i}
        adresses[index][:address]
    end

end