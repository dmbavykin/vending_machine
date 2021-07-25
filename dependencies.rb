require 'pry'
require 'json'
require 'forwardable'
require 'i18n'

Dir['./config/**/*.rb'].each { |f| require_relative f }
Dir['./lib/**/*.rb'].each { |f| require_relative f }
