require 'rest-client'
require 'json'

base_url = 'http://localhost:4567'

# Two new addresses
users = []
2.times do 
    users << JSON.parse(RestClient.post("#{base_url}/address/new", {}, {}).body)
end

# New transaction from user1 to user2 (both with no balance)
payload = {
    sender: users[0],
    amount: 10,
    receiver: users[1]
}
RestClient.post("#{base_url}/transaction/new", payload, {})

# Find the availale block (genesis in this case), and mine it
available_block = JSON.parse(RestClient.get("#{base_url}/block/available", {}).body)
puts available_block

payload = {
    address: users[1]
}
RestClient.post("#{base_url}/blockchain/mine", payload, {})

# New transaction from user2 to user1 (now user2 have 100 coins)
payload = {
    sender: users[1],
    amount: 40,
    receiver: users[0]
}
RestClient.post("#{base_url}/transaction/new", payload, {})

# New transaction from user1 to user2 (user1 has 40 coins but doesn't have the correct password and key files )
payload = {
    sender: users[0],
    amount: 20,
    receiver: users[1]
}
RestClient.post("#{base_url}/transaction/new", payload, {})

# Find all transactions (verifyed or not)
transactions = JSON.parse(RestClient.get("#{base_url}/transaction", {}).body)
puts transactions