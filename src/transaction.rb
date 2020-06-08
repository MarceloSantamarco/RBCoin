class Transaction

    attr_accessor :sender, :amount, :receiver

    def initialize(sender, amount, receiver)
        @sender = sender
        @amount = amount
        @receiver = receiver
    end

end