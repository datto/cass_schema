# CassSchema

A gem for managing multiple cassandra schemas across multiple clusters. CassSchema supports loading a table schema from scratch, as well as running a migration to apply a change to the schema. Unlike some other database migration tools, there is no stored state about which migrations have and have not been run. -- a migration is simply a CQL statement to be run against the database.

CassSchema operations apply to multiple 'datastores'. A datastore is a cluster, keyspace pair, so there may be multiple schemas for a single cluster, but only a single schema for a given cluster plus keyspace.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cass_schema'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cass_schema

## Usage

Before usage, CassSchema must be initialized with a set of datastore objects, as well as a base directory where the schema definitions live:

```ruby
CassSchema::Runner.datastores = CassSchema::YamlHelper.datastores('my/path/to/config.yml')
CassSchema::Runner.schema_base_path = 'my/path/to/schema/root'
```

Here the datastores are a list of `CassSchema::DataStore` objects. These may be build manually, or loaded from a yaml file using the `CassSchema::YamlHelper`. CassSchema is intentionally agnostic about the source of these datastores.

The schema_base_path is a directory where the schema definitions and migrations live. The structure of this directory should be:
```
<schema_base_path>/<datastore_name>/schema.cql
<schema_base_path>/<datastore_name>/migrations/<migration1>.cql
<schema_base_path>/<datastore_name>/migrations/<migration2>.cql
...

```

The contents of each cql file should be a list of CQL statements. Comments starting with '#' are supported, and each statement should be separated by two new lines.

schema.cql and each migration should be maintained by hand. It is recommended that schema.cql contain a complete list of CQL statements for the entire, up-to-date schema.

An example yml config and datastore schema definition are in the test/fixtures directory.

### Running migrations

To create all datastore schemas:

```
CassSchema::Runner.create_all
```

To create a particular datastore schemas:

```
CassSchema::Runner.create('datastore')
```

To drop all datastore schemas:

```
CassSchema::Runner.drop_all
```

To drop a particular datastore schemas:

```
CassSchema::Runner.drop('datastore')
```

To run a particular migration for a particular datastore:

```
CassSchema::Runner.migrate('datastore', 'migration')
```

Here the migration file 'migration.cql' should exist.

## Contributing

1. Fork it ( https://github.com/backupify/cass_schema/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
