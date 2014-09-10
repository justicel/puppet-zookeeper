module Puppet::Parser::Functions
  # Returns a Hash of Zookeeper server hostnames with the keys as their myid values.
  # Input is an array of fqdn's.
  newfunction(:get_zookeeper_servers_and_ids, :type => :rvalue) do |args|
    # args[0] = ['fqdn1', 'fqdn2', ...]
    result = Hash.new
    server_id = 1
    args[0].each do |fqdn|
      result[server_id] = fqdn
      server_id = server_id + 1
    end
    return result
  end
end
