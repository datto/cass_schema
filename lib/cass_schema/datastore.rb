require_relative 'errors'
require_relative 'statement_loader'
require_relative 'cluster'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object'

module CassSchema
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

    attr_reader :schema_base_path, :logger

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

    # Creates the datastore
    def create
      run_statement(create_keyspace, general_client)
      create_statements.each { |statement| run_statement(statement, client) }
    end

    # Drops the datastore
    def drop
      run_statement(drop_keyspace, general_client)
    end

    # Runs a given migration for this datastore
    # @param migration_name [String] the name of the migration
    def migrate(migration_name)
      migration_statements(migration_name).each { |statement| run_statement(statement, client) }
    end

    # A Cassava client connected to the cluster and keyspace with which this datastore is associated
    # @return [Cassandra::Session]
    def client
      @client ||= cluster.connection.connect(keyspace)
    end

    # A Cassava client connected to the cluster with which this datastore is associated
    # @return [Cassandra::Session]
    def general_client
      @general_client ||= cluster.connection.connect
    end

    # Internal method used by Runner to pass state into the datastore
    def _setup(options = {})
      @schema_base_path = options[:schema_base_path]
      @logger = options[:logger]
    end

    private

    def run_statement(statement, client)
      log("CassSchema: #{statement}")
      client.execute(statement)
    rescue Cassandra::Errors::ConfigurationError
      # Special case if we cannot create/drop the keyspace, do nothing
    rescue => e
      log(e, :error)
      raise SchemaError.create(e, statement)
    end

    def create_statements
      StatementLoader.statements(schema_base_path, schema, 'schema.cql')
    end

    def migration_statements(migration_name)
      StatementLoader.statements(schema_base_path, schema, 'migrations', "#{migration_name}.cql")
    end

    def create_keyspace
      "CREATE KEYSPACE #{keyspace} with replication = #{replication}"
    end

    def drop_keyspace
      "DROP KEYSPACE #{keyspace}"
    end

    def log(msg, level = :info)
      logger.try { |l| l.send(level, msg) }
    end
  end if !defined?(DataStore)
end
