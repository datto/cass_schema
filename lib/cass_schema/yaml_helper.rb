require_relative 'datastore'
require 'yaml'

module CassSchema
  class YamlHelper
    def self.datastores(config_file)
      config = YAML.load(File.open(config_file).read)
      config['datastores'].map do |name, ds_config|
        ds_config[:cluster] = Cluster.build(ds_config)
        DataStore.build(name, ds_config)
      end
    end
  end
end
