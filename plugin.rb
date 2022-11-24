# frozen_string_literal: true

# name: Karota credits
# about: Credit system for Karota
# version: 0.0.1
# authors: Karota
# url: https://github.com/charnelclamosa/credit-system
# required_version: 2.7.0

enabled_site_setting :credit_system_enabled

load File.expand_path('lib/karota_credits/engine.rb', __dir__)

after_initialize do
  Discourse::Application.routes.append do
    mount ::KarotaCredits::Engine, at: 'credits'
  end
end
