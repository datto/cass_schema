require 'rake'

namespace :cass do
  namespace :schema do

    desc "Create the cassandra schema for all datastores"
    task :create_all, [:datastore] => :environment do |t, args|
      CassSchema::Runner.create_all
    end

    desc "Drop the cassandra schema for all datastores"
    task :drop_all, [:datastore] => :environment do |t, args|
      CassSchema::Runner.drop_all
    end

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

    desc "Run the specified cassandra schema migration for the specified datastore"
    task :migrate, [:datastore, :migration] => :environment do |t, args|
      raise ArgumentError.new('datastore argument required') unless args[:datastore]
      raise ArgumentError.new('migration argument required') unless args[:migration]
      CassSchema::Runner.migrate(args[:datastore], args[:migration])
    end
  end
end
