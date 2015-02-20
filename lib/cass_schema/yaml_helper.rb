require_relative 'datastore'
require 'yaml'

module CassSchema
  class YamlHelper
    def self.datastores(config_file)
      config = YAML.load(File.open(config_file).read)
      config['datastores'].map { |name, ds_config| DataStore.create(name, ds_config) }
    end
  end
end
