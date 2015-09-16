module CassSchema
  class Runner

    class DropCommandsNotAllowed < StandardError
      def initialize(*_)
        super('Drop commands have been disabled by the :disallow_drops option')
      end
    end

    attr_reader :datastores, :schema_base_path, :logger, :cluster_builder, :disallow_drops

    # Create a new Runner
    # @option options [Array<CassSchema::Datastore>] :datastores - The list of datastore objects for which schemas
    #    will be managed.
    # @option options [String] :schema_bath_path - The directory where schema definitions live. In a rails env,
    #   this defaults to <rails root>/cass_schema.
    # @option options [#info|#error] :logger optional logger to use when creating schemas
    # @option options [Boolean] :disallow_drops Defaults to false. If set to true,
    # drop commands will raise an exception instead of executing the command.
    def initialize(options = {})
      options[:schema_base_path] ||= defined?(::Rails) ? File.join(::Rails.root, 'cass_schema') : nil

      @datastores = options[:datastores]
      @schema_base_path = options[:schema_base_path]
      @logger = options[:logger]
      @disallow_drops = options[:disallow_drops]

      raise ":datastores is a required argument!" unless @datastores

      @datastores.each { |ds| ds.setup(options) }
    end

    # Create all schemas for all datastores
    def create_all
      datastores.each { |d| d.create }
    end

    # Drop all schemas for all datastores
    def drop_all
      raise DropCommandsNotAllowed if disallow_drops
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
      raise DropCommandsNotAllowed if disallow_drops
      datastore_lookup(datastore_name).drop
    end

    # Run a particular named migration for a datastore
    # @param [String] datastore_name
    # @param [String] migration_name
    def migrate(datastore_name, migration_name)
      datastore_lookup(datastore_name).migrate(migration_name)
    end

    def datastore_lookup(datastore_name)
      @datastore_lookup ||= Hash[datastores.map { |ds| [ds.name, ds] }]
      @datastore_lookup[datastore_name] || (raise ArgumentError.new("CassSchema datastore #{datastore_name} not found"))
    end

    # The class methods for Runner are the same as the instance methods, which delegate to a singleton. To set up the
    # singleton, call Runner#setup.
    class << self
      # (see Runner#initialize)
      def setup(options = {})
        @runner = Runner.new(options)
      end

      (Runner.instance_methods - Object.instance_methods).each do |method|
        define_method(method) do |*args|
          @runner.send(method, *args)
        end
      end
    end
  end
end
