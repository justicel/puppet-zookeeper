module Puppet::Parser::Functions
  # Takes in a Hash (result of get_zookeeper_servers_and_ids) and returns an Array.
  # Each value in the array is in the format 'myid:fqdn'.
  # This can be parsed easily into resources within a Puppet manifest using split(var, ':')
  # and result[0] / result[1]
  newfunction(:format_zookeeper_servers_and_ids, :type => :rvalue) do |args|
    # args[0] = {'1' => 'fqdn1', '2' => 'fqdn2'}
    result = Array.new
    args[0].each do |key, value|
      result.push("#{key}:#{value}")
    end
    return result
  end
end
