# frozen_string_literal: true

module Cards
  class Base
    NUMBER_LENGTH = 16

    WITHDRAW_PERCENT = 0
    WITHDRAW_FIXED = 0
    PUT_PERCENT = 0
    PUT_FIXED = 0
    SENDER_PERCENT = 0
    SENDER_FIXED = 0

    attr_accessor :balance
    attr_reader :number, :taxes

    class << self
      include VIEW

      def generate_number
        Array.new(NUMBER_LENGTH) { rand(10) }.join
      end

      def update_balance(card, amount, tax, operation:)
        operation == :withdraw ? card.balance -= (amount - tax) : card.balance += (amount - tax)
      end
    end

    def initialize(_balance)
      @number = self.class.generate_number
    end

    private

    def calculate_tax(amount, percent_tax, fixed_tax)
      (amount / 100) * percent_tax + fixed_tax
    end

    def put_fixed
      PUT_FIXED
    end

    def put_percent
      PUT_PERCENT
    end

    def withdraw_fixed
      WITHDRAW_FIXED
    end

    def withdraw_percent
      WITHDRAW_PERCENT
    end

    def send_fixed
      SENDER_FIXED
    end

    def send_percent
      SENDER_PERCENT
    end
  end
end
