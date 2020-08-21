# frozen_string_literal: true

class Builder
  include DBHelper

  def self.build
    extend VIEW

    builder = new
    yield builder

    return show_errors(builder.errors) unless builder.errors.values.all?(&:empty?)

    builder.account
  end

  attr_reader :account, :errors

  def initialize
    @account = Account.new

    @errors = {
      name: nil,
      age: nil,
      login: nil,
      password: nil
    }
  end

  def input_name(name)
    errors[:name] = AccountValidator.check_name(name)

    return unless errors[:name].empty?

    account.name = name
  end

  def input_age(age)
    errors[:age] = AccountValidator.check_age(age)

    return unless errors[:age].empty?

    account.age = age
  end

  def input_login_credentials(login, password)
    input_login(login)
    input_password(password)
  end

  def input_empty_cards_list
    account.cards = []
  end

  private

  def input_login(login)
    errors[:login] = AccountValidator.check_login(login)

    return unless errors[:login].empty?

    account.login = login
  end

  def input_password(password)
    errors[:password] = AccountValidator.check_password(password)

    return unless errors[:password].empty?

    account.password = obtain_hashsum password
  end
end
