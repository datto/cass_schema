require 'rake'

namespace :cass do
  namespace :schema do
    desc "Create the cassandra schema for the specified datastore"
    task :create, [:datastore] => :environment do |t, args|
      raise ArgumentError.new('datastore argument required') unless args[:datastore]
      CassSchema::Runner.create(args[:datastore])
    end

    desc "Drop the cassandra schema for the specified datastore"
    task :drop, [:datastore] => :environment do |t, args|
      raise ArgumentError.new('datastore argument required') unless args[:datastore]
      CassSchema::Runner.drop(args[:datastore])
    end
  end
end
