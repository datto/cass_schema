module CassSchema
  class SchemaError < StandardError
    def self.create(cause, statement = nil)
      new("Error #{cause} when running statement: #{statement}")
    end
  end
end
