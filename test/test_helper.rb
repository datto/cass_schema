require 'rubygems'
require 'pry'
require 'minitest/autorun'
require 'minitest/should'


require 'cass_schema'

class Minitest::Should::TestCase
  def self.xshould(*args)
    puts "Disabled test: #{args}"
  end
end

def create_client
  c = Cassandra.cluster(port: 9242)
  c.connect
end
