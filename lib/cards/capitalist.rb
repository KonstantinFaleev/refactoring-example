# frozen_string_literal: true

module Cards
  class Capitalist < Base
    WITHDRAW_PERCENT = 4
    PUT_FIXED = 10
    SENDER_PERCENT = 10

    def initialize(balance: 100)
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

    def send_percent
      SENDER_PERCENT
    end
  end
end
