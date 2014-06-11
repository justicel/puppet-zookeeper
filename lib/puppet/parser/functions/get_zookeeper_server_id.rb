module Puppet::Parser::Functions
  # Returns the Server ID for the FQDN provided, based on the Server List provided.
  newfunction(:get_zookeeper_server_id, :type => :rvalue) do |args|
    # args[0] = ['fqdn1', 'fqdn2']
    # args[1] = 'fqdn1'
    result = args[0].key(args[1])
    return result.to_s
  end
end
