require 'cassandra'
require 'yaml'

module CassSchema

  class Runner
    class << self
      attr_accessor :config_file
      attr_accessor :schema_base_path

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
        datastores[datastore_name].create
      end

      # Drop the schema for a particular datastore
      # @param [String] datastore_name
      def drop(datastore_name)
        datastores[datastore_name].drop
      end

      # Run a particular named migration for a datastore
      # @param [String] datastore_name
      # @param [String] migration_name
      def migrate(datastore_name, migration_name)
        datastores[datastore_name].migrate(migration_name)
      end

      private

      # If in a rails env, default to the o
      @config_file ||= defined?(::Rails) ? File.join(::Rails.root, 'config', 'cass-datastores.yml') : nil
      @schema_base_path ||= defined?(::Rails) ? File.join(::Rails.root, 'cass_schema') : nil

      def config
        @config ||= YAML.load(File.open(config_file).read)
      end

      def datastores
        @datastores ||=
          begin
            datastore_list = config['datastores'].map do |name, ds_config|
              hosts = ds_config['hosts'].split(/\s*,\s*/).map { |host| host.strip }
              port = ds_config['port'].to_i
              DataStore.new(name, hosts, port)
            end

            Hash[datastore_list.map { |ds| [ds.name, ds] }]
          end
      end
    end
  end

  class FileConfig

    class << self
      def path_for_datastore(datastore_name)
        File.join(Runner.schema_base_path, datastore_name)
      end

      def statements(datastore_name, *path_parts)
        file_path = File.join(path_for_datastore(datastore_name), path_parts)
        file = File.open(file_path).read

        # Parse the individual CQL statements as a list from the file. To do so:
        # - assume statements are separated by two new lines
        # - strip comments and empty lines from each statement
        # - remove statements that are empty
        statements = file.split(/\n{2,}/).map do |statement|
          statement
            .split(/\n/)
            .select { |l| l !~ /^\s*#/ }
            .select { |l| l !~ /^\s*$/ }
            .join("\n")
        end

        statements.select { |s| s.length > 0 }
      end
    end

  end

  DataStore = Struct.new(:name, :hosts, :port) do
    def client
      @client ||= begin
                     cluster = Cassandra.cluster(:hosts => hosts, :port => port)
                     cluster.connect
                   end
    end

    def create
      run_statements(up_statements)
    end

    def drop
      run_statements(down_statements)
    end

    def migrate(migration_name)
      run_statements(migration_statements(migration_name))
    end

    def run_statements(statements)
      statements.each do |cql_statement|
        begin
          client.execute(cql_statement)
        rescue => e
          puts "Failed executing statement: #{cql_statement} - #{e}"
          break
        end
      end
    end

    def up_statements
      FileConfig.statements(name, 'schema.cql')
    end

    def down_statements
      FileConfig.statements(name, 'drop.cql')
    end

    def migration_statements(migration_name)
      FileConfig.statements(name, 'migrations', "#{migration_name}.cql")
    end
  end
end
