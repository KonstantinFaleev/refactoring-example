# frozen_string_literal: true

module Cards
  class Virtual < Base
    WITHDRAW_PERCENT = 88
    PUT_FIXED = 1
    SENDER_PERCENT = 1

    def initialize(balance: 150)
      super

      @balance = balance
    end

    def withdraw_tax(amount)
      calculate_tax(amount, withdraw_percent, withdraw_fixed)
    end

    def put_tax(amount)
      calculate_tax(amount, put_percent, put_fixed)
    end

    def send_tax(amount)
      calculate_tax(amount, send_percent, send_fixed)
    end

    private

    def withdraw_percent
      WITHDRAW_PERCENT
    end

    def put_fixed
      PUT_FIXED
    end

    def send_fixed
      SENDER_PERCENT
    end
  end
end
