require_relative 'lib/load'

class Account
  attr_accessor :login, :name, :card, :password, :file_path

  def initialize
    @errors = []
    @file_path = 'accounts.yml'
  end

  def console
    puts I18n.t(:hello_message)

    a = gets.chomp

    if a == 'create'
      create
    elsif a == 'load'
      load
    else
      exit
    end
  end

  def create
    loop do
      name_input
      age_input
      login_input
      password_input
      break unless @errors.length != 0
      @errors.each do |e|
        puts e
      end
      @errors = []
    end

    @card = []
    new_accounts = accounts << self
    @current_account = self
    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml }
    main_menu
  end

  def load
    loop do
      if !accounts.any?
        return create_the_first_account
      end

      puts I18n.t(:login_input)
      login = gets.chomp
      puts I18n.t(:password_input)
      password = gets.chomp

      if accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
        a = accounts.select { |a| login == a.login }.first
        @current_account = a
        break
      else
        puts I18n.t(:load_error)
        next
      end
    end
    main_menu
  end

  def create_the_first_account
    puts I18n.t(:create_the_first_account)
    if gets.chomp == 'y'
      create
    else
      console
    end
  end

  def main_menu
    loop do
      puts I18n.t(:main_menu_message, name: "#{@current_account.name}")

      case gets.chomp
      when 'SC'
        show_cards
      when 'CC'
        create_card
      when 'DC'
        destroy_card
      when 'PM'
        put_money
      when 'WM'
        withdraw_money
      when 'SM'
        send_money
      when 'DA'
        destroy_account
        exit
      when 'exit'
        exit
        break
      else
        puts I18n.t(:wrong_command)
      end
    end
  end

  def create_card
    loop do
      puts I18n.t(:create_card_message)

      ct = gets.chomp
      if ct == 'usual' || ct == 'capitalist' || ct == 'virtual'
        if ct == 'usual'
          card = {
            type: 'usual',
            number: 16.times.map{rand(10)}.join,
            balance: 50.00
          }
        elsif ct == 'capitalist'
          card = {
            type: 'capitalist',
            number: 16.times.map{rand(10)}.join,
            balance: 100.00
          }
        elsif ct == 'virtual'
          card = {
            type: 'virtual',
            number: 16.times.map{rand(10)}.join,
            balance: 150.00
          }
        end
        cards = @current_account.card << card
        @current_account.card = cards
        new_accounts = []
        accounts.each do |ac|
          if ac.login == @current_account.login
            new_accounts.push(@current_account)
          else
            new_accounts.push(ac)
          end
        end
        File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
        break
      else
        puts I18n.t(:wrong_card_type)
      end
    end
  end

  def destroy_card
    loop do
      if @current_account.card.any?
        puts I18n.t(:want_to_delete)

        @current_account.card.each_with_index do |c, i|
          puts I18n.t(:list_cards, card: "#{c[:number]}", type: "#{c[:type]}", index: "#{i + 1}")
        end
        puts "press `exit` to exit\n"
        answer = gets.chomp
        break if answer == 'exit'
        if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
          puts I18n.t(:accept_delete_account, card_number: "#{@current_account.card[answer&.to_i.to_i - 1][:number]}?[y/n]")
          a2 = gets.chomp
          if a2 == 'y'
            @current_account.card.delete_at(answer&.to_i.to_i - 1)
            new_accounts = []
            accounts.each do |ac|
              if ac.login == @current_account.login
                new_accounts.push(@current_account)
              else
                new_accounts.push(ac)
              end
            end
            File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
            break
          else
            return
          end
        else
          puts I18n.t(:wrong_number_input)
        end
      else
        puts I18n.t(:active_card_error)
        break
      end
    end
  end

  def show_cards
    if @current_account.card.any?
      @current_account.card.each do |c|
        puts "- #{c[:number]}, #{c[:type]}"
      end
    else
      puts I18n.t(:active_card_error)
    end
  end

  def withdraw_money
    puts I18n.t(:choose_card_withdraw)
    answer, a2, a3 = nil
    if @current_account.card.any?
      @current_account.card.each_with_index do |c, i|
        puts I18n.t(:list_cards, card: "#{c[:number]}", type: "#{c[:type]}", index: "#{i + 1}")
      end
      puts I18n.t(:exit_msg)
      loop do
        answer = gets.chomp
        break if answer == 'exit'
        if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
          current_card = @current_account.card[answer&.to_i.to_i - 1]
          loop do
            puts I18n.t(:money_amount_to_withdraw)
            a2 = gets.chomp
            if a2&.to_i.to_i > 0
              money_left = current_card[:balance] - a2&.to_i.to_i - withdraw_tax(current_card[:type], a2&.to_i.to_i)
              if money_left > 0
                current_card[:balance] = money_left
                @current_account.card[answer&.to_i.to_i - 1] = current_card
                new_accounts = []
                accounts.each do |ac|
                  if ac.login == @current_account.login
                    new_accounts.push(@current_account)
                  else
                    new_accounts.push(ac)
                  end
                end
                File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
                puts I18n.t(:withdraw_money_message, money: "#{a2&.to_i.to_i}", current_card: "#{current_card[:number]}", balance: "#{current_card[:balance]}", tax: "#{withdraw_tax(current_card[:type], a2&.to_i.to_i)}")
                return
              else
                puts I18n.t(:money_amount_error)
                return
              end
            else
              puts I18n.t(:uncorrect_input_amount)
              return
            end
          end
        else
          puts I18n.t(:wrong_number_input)
          return
        end
      end
    else
      puts I18n.t(:active_card_error)
    end
  end

  def put_money
    puts I18n.t(:choose_card_putting)

    if @current_account.card.any?
      @current_account.card.each_with_index do |c, i|
        puts I18n.t(:list_cards, card: "#{c[:number]}", type: "#{c[:type]}", index: "#{i + 1}")
      end
      puts I18n.t(:exit_msg)
      loop do
        answer = gets.chomp
        break if answer == 'exit'
        if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
          current_card = @current_account.card[answer&.to_i.to_i - 1]
          loop do
            puts I18n.t(:puts_money_amount)
            a2 = gets.chomp
            if a2&.to_i.to_i > 0
              if put_tax(current_card[:type], a2&.to_i.to_i) >= a2&.to_i.to_i
                puts I18n.t(:high_tax_error)
                return
              else
                new_money_amount = current_card[:balance] + a2&.to_i.to_i - put_tax(current_card[:type], a2&.to_i.to_i)
                current_card[:balance] = new_money_amount
                @current_account.card[answer&.to_i.to_i - 1] = current_card
                new_accounts = []
                accounts.each do |ac|
                  if ac.login == @current_account.login
                    new_accounts.push(@current_account)
                  else
                    new_accounts.push(ac)
                  end
                end
                File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml }
                puts I18n.t(:put_money_message, money: "#{a2&.to_i.to_i}", card: "#{current_card[:number]}", balance: "#{current_card[:balance]}", tax: "#{put_tax(current_card[:type], a2&.to_i.to_i)}")
                return
              end
            else
              puts I18n.t(:uncorrect_puts_input_amount)
              return
            end
          end
        else
          puts I18n.t(:wrong_number_input)
          return
        end
      end
    else
      puts I18n.t(:active_card_error)
    end
  end

  def send_money
    puts I18n.t(:choose_send_card)

    if @current_account.card.any?
      @current_account.card.each_with_index do |c, i|
        puts I18n.t(:list_cards, card: "#{c[:number]}", type: "#{c[:type]}", index: "#{i + 1}")
      end
      puts I18n.t(:exit_msg)
      answer = gets.chomp
      exit if answer == 'exit'
      if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
        sender_card = @current_account.card[answer&.to_i.to_i - 1]
      else
        puts I18n.t(:choose_correct_card)
        return
      end
    else
      puts I18n.t(:active_card_error)
      return
    end

    puts I18n.t(:enter_recipient_card)
    a2 = gets.chomp
    if a2.length > 15 && a2.length < 17
      all_cards = accounts.map(&:card).flatten
      if all_cards.select { |card| card[:number] == a2 }.any?
        recipient_card = all_cards.select { |card| card[:number] == a2 }.first
      else
        puts I18n.t(:card_not_exist, number: "#{a2}")
        return
      end
    else
      puts I18n.t(:correct_number_card_error)
      return
    end

    loop do
      puts I18n.t(:money_amount_to_withdraw)
      a3 = gets.chomp
      if a3&.to_i.to_i > 0
        sender_balance = sender_card[:balance] - a3&.to_i.to_i - sender_tax(sender_card[:type], a3&.to_i.to_i)
        recipient_balance = recipient_card[:balance] + a3&.to_i.to_i - put_tax(recipient_card[:type], a3&.to_i.to_i)

        if sender_balance < 0
          puts I18n.t(:money_amount_error)
        elsif put_tax(recipient_card[:type], a3&.to_i.to_i) >= a3&.to_i.to_i
          puts I18n.t(:sender_card_amount_error)
        else
          sender_card[:balance] = sender_balance
          @current_account.card[answer&.to_i.to_i - 1] = sender_card
          new_accounts = []
          accounts.each do |ac|
            if ac.login == @current_account.login
              new_accounts.push(@current_account)
            elsif ac.card.map { |card| card[:number] }.include? a2
              recipient = ac
              new_recipient_cards = []
              recipient.card.each do |card|
                if card[:number] == a2
                  card[:balance] = recipient_balance
                end
                new_recipient_cards.push(card)
              end
              recipient.card = new_recipient_cards
              new_accounts.push(recipient)
            end
          end
          File.open('accounts.yml', 'w') { |f| f.write new_accounts.to_yaml }
          puts I18n.t(:put_money_message, money: "#{sender_card[:number]}", card: "#{recipient_balance}", balance: "#{recipient_balance}", tax: "#{put_tax(sender_card[:type], a3&.to_i.to_i)}")
          puts I18n.t(:put_money_message, money: "#{a3&.to_i.to_i}", card: "#{a2}", balance: "#{sender_balance}", tax: "#{sender_tax(sender_card[:type], a3&.to_i.to_i)}")
          break
        end
      else
        puts I18n.t(:wrong_number_input)
      end
    end
  end

  def destroy_account
    puts I18n.t(:destroy_account)
    a = gets.chomp
    if a == 'y'
      new_accounts = []
      accounts.each do |ac|
        if ac.login == @current_account.login
        else
          new_accounts.push(ac)
        end
      end
      File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml }
    end
  end

  private

  def name_input
    puts I18n.t(:name_input)
    @name = gets.chomp
    unless @name != '' && @name[0].upcase == @name[0]
      @errors.push(I18n.t(:empty_name_error))
    end
  end

  def login_input
    puts I18n.t(:login_input)
    @login = gets.chomp
    if @login == ''
      @errors.push(I18n.t(:login_present_error))
    end

    if @login.length < 4
      @errors.push(I18n.t(:length_name_error))
    end

    if @login.length > 20
      @errors.push(I18n.t(:short_name_error))
    end

    if accounts.map { |a| a.login }.include? @login
      @errors.push(I18n.t(:account_exist_error))
    end
  end

  def password_input
    puts I18n.t(:password_input)
    @password = gets.chomp
    if @password == ''
      @errors.push(I18n.t(:password_present_error))
    end

    if @password.length < 6
      @errors.push(I18n.t(:password_longer_error))
    end

    if @password.length > 30
      @errors.push(I18n.t(:password_shorter_error))
    end
  end

  def age_input
    puts I18n.t(:age_input)
    @age = gets.chomp
    if @age.to_i.is_a?(Integer) && @age.to_i >= 23 && @age.to_i <= 90
      @age = @age.to_i
    else
      @errors.push(I18n.t(:age_error))
    end
  end

  def accounts
    if File.exists?('accounts.yml')
      YAML.load_file('accounts.yml')
    else
      []
    end
  end

  def withdraw_tax(type, amount)
    if type == 'usual'
      return amount * 0.05
    elsif type == 'capitalist'
      return amount * 0.04
    elsif type == 'virtual'
      return amount * 0.88
    end
    0
  end

  def put_tax(type, amount)
    if type == 'usual'
      return amount * 0.02
    elsif type == 'capitalist'
      return 10
    elsif type == 'virtual'
      return 1
    end
    0
  end

  def sender_tax(type, amount)
    if type == 'usual'
      return 20
    elsif type == 'capitalist'
      return amount * 0.1
    elsif type == 'virtual'
      return 1
    end
    0
  end
end
