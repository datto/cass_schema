require 'cassandra'

module CassSchema
  # A struct representing a Cassandra cluster.
  # @param [Cassandra::Cluster] connection to the cassandra cluster to be used.
  Cluster = Struct.new(:connection) do
    def self.build(hash)
      l = hash.with_indifferent_access

      if l[:hosts]
        l[:connection] ||= Cassandra.cluster(hosts: l[:hosts], port: l[:port])
      end

      new(l[:connection])
    end
  end if !defined?(Cluster)
end
