require 'cassandra'

module CassSchema
  # A struct representing a Cassandra cluster.
  # @param [Array<String>] A list of hosts defining the cluster
  # @param [Integer] the port to use for the cluster
  # @param [Cassandra::Cluster] connection to the cassandra cluster to be used.
  Cluster = Struct.new(:hosts, :port, :connection) do
    def self.build(hash)
      l = hash.with_indifferent_access
      l[:connection] ||= Cassandra.cluster(:hosts => l[:hosts], :port => l[:port])

      new(l[:hosts], l[:port], l[:connection])
    end
  end if !defined?(Cluster)
end
