# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
if Rails.env.production?
  abort('The Rails environment is running in production mode!')
end
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
# begin
#   ActiveRecord::Migration.maintain_test_schema!
# rescue ActiveRecord::PendingMigrationError => e
#   puts e.to_s.strip
#   exit 1
# end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

SAMPLE_GOOD_IPS = 4
SAMPLE_BAD_IPS = 3

def rand_sha256
  SecureRandom.hex(32)
end

def rand_good_ip
  IPAddr.new(Forgery(:internet).ip_v4 + '/255.255.255.240')
end

def rand_bad_ip
  IPAddr.new(Forgery(:internet).ip_v4)
end

def good_ips
  good_ips = []
  ip = rand_good_ip
  SAMPLE_GOOD_IPS.times { |n| good_ips << IPAddr.new(ip.to_i + n + 1, Socket::AF_INET) }
  good_ips.uniq
end

def bad_ips
  bad_ips = []
  SAMPLE_BAD_IPS.times { bad_ips << IPAddr.new(Forgery(:internet).ip_v4) }
  bad_ips.uniq
end

def all_ips
  (good_ips + bad_ips).map(&:to_i)
end

# TODOs move to app level helper
def convert_to_ip(values)
  values.map { |s| [s.to_i].pack('N').unpack('CCCC').join('.') }
end

def prepare_events
  $all_events = []
  all_ips.each do |ip|
    event = Definitions::IpEvent.encode(Definitions::IpEvent.new(app_sha256: app_sha256, ip: ip))
    EventCreationService.new(event).process
  end
end
