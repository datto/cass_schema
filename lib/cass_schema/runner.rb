require 'cassandra'

module CassSchema
  class Runner
    class << self
      attr_writer :datastores
      attr_writer :schema_base_path
      attr_accessor :logger

      # Create all schemas for all datastores
      def create_all
        datastores.each { |d| d.create }
      end

      # Drop all schemas for all datastores
      def drop_all
        datastores.each { |d| d.drop }
      end

      # Create the schema for a particular datastore
      # @param [String] datastore_name
      def create(datastore_name)
        datastore_lookup(datastore_name).create
      end

      # Drop the schema for a particular datastore
      # @param [String] datastore_name
      def drop(datastore_name)
        datastore_lookup(datastore_name).drop
      end

      # Run a particular named migration for a datastore
      # @param [String] datastore_name
      # @param [String] migration_name
      def migrate(datastore_name, migration_name)
        datastore_lookup(datastore_name).migrate(migration_name)
      end

      def schema_base_path
        @schema_base_path ||= defined?(::Rails) ? File.join(::Rails.root, 'cass_schema') : nil
      end

      def datastore_lookup(datastore_name)
        @datastore_lookup ||= Hash[datastores.map { |ds| [ds.name, ds] }]
        @datastore_lookup[datastore_name] || (raise ArgumentError.new("CassSchema datastore #{datastore_name} not found"))
      end

      private

      def datastores
        raise "CassSchema::Runner.datastores must be initialized to a list of CassSchema::DataStore objects!" unless @datastores
        @datastores
      end
    end
  end
end
