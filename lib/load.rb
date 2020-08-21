# frozen_string_literal: true

require 'i18n'
require 'yaml'
require 'pry'
require 'digest'

require_relative 'helpers/db_helper'
require_relative 'helpers/validation_helper'

require_relative 'validation/card_validator'
require_relative 'validation/account_validator'
require_relative 'validation/transaction_validator'

require_relative 'app/view'

require_relative 'cards/base'
require_relative 'cards/usual'
require_relative 'cards/capitalist'
require_relative 'cards/virtual'

require_relative 'app/builder'
require_relative 'app/account'
require_relative 'app/console'

require_relative '../initializers/i18n'

I18n.config.load_path << Dir[File.expand_path('config/locales').concat('/*.yml')]
