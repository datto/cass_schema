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
end
