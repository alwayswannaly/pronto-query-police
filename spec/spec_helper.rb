require 'simplecov'
SimpleCov.start

require 'rspec'
require 'pronto/query_police'

Dir.glob(Dir.pwd + '/spec/support/**/*.rb') { |file| require file }

RSpec.configure do |c|
  c.include RepositoryHelper
end
