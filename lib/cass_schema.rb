require 'cass_schema/version'
require 'cass_schema/runner'
require 'cass_schema/datastore'
require 'cass_schema/yaml_helper'

module CassSchema; end

if defined?(::Rails)
  module CassSchema
    module Rails
      class Railtie < ::Rails::Railtie
        rake_tasks do
          load "cass_schema/tasks/schema.rake"
        end
      end
    end
  end
end
