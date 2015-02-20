require_relative '../test_helper'

module CassSchema
  class RunnerTest < MiniTest::Should::TestCase

    setup do
      base_path = '../fixtures'
      Runner.datastores = YamlHelper.datastores(File.join(base_path, 'test_config.yml'))
      Runner.schema_base_path = base_path
    end

    teardown do
      Runner.drop_all
    end

    def tables_for_keyspace(keyspace)
      create_client.execute('SELECT * FROM system.schema_columnfamilies').rows.to_a.select { |t| t["keyspace_name"] == keyspace}
    end

    def schema_for_table(keyspace, table)
      create_client.execute('SELECT * FROM system.schema_columns').rows.to_a.select do |t|
        (t["keyspace_name"] == 'test_keyspace') && (t['columnfamily_name'] == table)
      end
    end

    context 'creating a schema' do
      should 'be able to create a datastore' do
        Runner.create('test_datastore')
        tables = tables_for_keyspace('test_keyspace')
        assert_equal %w(test test2).to_set, tables.map { |t| t['columnfamily_name'] }.to_set
      end

      should 'raise a SchemaError and not execute subsequent schema commands when a schema contains errors' do
        assert_raises(SchemaError) { Runner.create('invalid_datastore') }
      end

      should 'raise a misisng file error if schema for a datastore does not exist' do
        assert_raises(Errno::ENOENT) { Runner.create('missing_datastore') }
      end

      should 'raise an error if a datastore does not exist' do
        assert_raises(ArgumentError) { Runner.create('nonexistent_datastore') }
      end
    end

    context 'dropping a schema' do
      should 'be able to drop a datastore' do
        Runner.create('test_datastore')
        Runner.drop('test_datastore')
        tables = tables_for_keyspace('test_keyspace')
        assert_equal [], tables.map(&:columnfamily_name)
      end

      should 'raise an error if a datastore does not exist' do
        assert_raises(ArgumentError) { Runner.drop('nonexistent_datastore') }
      end
    end

    context 'running a migration' do
      should 'be able to run a migration for a datastore' do
        Runner.create('test_datastore')
        Runner.migrate('test_datastore', 'migration')
        schema = schema_for_table('test_datastore', 'test')

        column = schema.find { |col| col['column_name'] == 'new_column'}
        assert column
        assert_equal 'org.apache.cassandra.db.marshal.Int32Type', column['validator']
      end

      should 'raise an error if a datastore does not exist' do
        assert_raises(ArgumentError) { Runner.create('nonexistent_datastore') }
      end
    end
  end
end
