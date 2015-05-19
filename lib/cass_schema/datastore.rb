require_relative 'runner'
require_relative 'errors'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object'

module CassSchema
  # A struct representing a Cassandra cluster.
  # @param [Array<String>] A list of hosts defining the cluster
  # @param [Integer] the port to use for the cluster
  Cluster = Struct.new(:hosts, :port) do
    def self.build(hash)
      l = hash.with_indifferent_access
      new(l[:hosts], l[:port])
    end
  end if !defined?(Cluster)

  # A struct representing a datastore, composed of the following fields:
  # @param [String] name of the datastore
  # @param [CassSchema::Cluster] A list of hosts and a port representing the cluster.
  # @param [String] keyspace
  # @param [String] A string defining the options with which the keyspace should be created, e.g.:
  # "{ 'class' : 'SimpleStrategy', 'replication_factor' : 3 }"
  # @param [String] The name of the schema directory within the cass_schema directory, typically the same as the name.
  # statements are separated by two new lines, and a statement cannot have two newlines inside of it
  # comments start with '#'
  DataStore = Struct.new(:name, :cluster, :keyspace, :replication, :schema) do

    # Creates a datastore object from a hash containing the required keys
    # @param [String] name of the data store
    # @option [CassSchema::Cluster] :cluster
    # @option [String] :schema, defines the schema directory used. Sefaults to the name if not given.
    # @option [String] :keyspace
    # @option [String] :replication
    def self.build(name, hash)
      l = hash.with_indifferent_access
      schema = l[:schema] || name
      new(name, l[:cluster], l[:keyspace], l[:replication], schema)
    end

    def create
      run_statement(create_keyspace, general_client)
      create_statements.each { |statement| run_statement(statement, client) }
    end

    def drop
      run_statement(drop_keyspace, general_client)
    end

    def migrate(migration_name)
      migration_statements(migration_name).each { |statement| run_statement(statement, client) }
    end

    private

    def client
      @client ||= begin
                    cl = Cassandra.cluster(:hosts => cluster.hosts, :port => cluster.port)
                    cl.connect(keyspace)
                  end
    end

    def general_client
      @general_client ||= begin
                            cl = Cassandra.cluster(:hosts => cluster.hosts, :port => cluster.port)
                            cl.connect
                          end
    end

    def run_statement(statement, client)
      log("CassSchema: #{statement}")
      client.execute(statement)
    rescue => e
      log(e, :error)
      raise SchemaError.create(e, statement)
    end

    def create_statements
      StatementLoader.statements(schema, 'schema.cql')
    end

    def migration_statements(migration_name)
      StatementLoader.statements(schema, 'migrations', "#{migration_name}.cql")
    end

    def create_keyspace
      "CREATE KEYSPACE IF NOT EXISTS #{keyspace} with replication = #{replication}"
    end

    def drop_keyspace
      "DROP KEYSPACE IF EXISTS #{keyspace}"
    end

    def log(msg, level = :info)
      Runner.logger.try { |l| l.send(level, msg) }
    end
  end if !defined?(DataStore)

  class StatementLoader
    class << self
      def path_for_schema(schema)
        File.join(Runner.schema_base_path, schema)
      end

      def statements(schema, *path_parts)
        file_path = File.join(path_for_schema(schema), path_parts)
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
end
