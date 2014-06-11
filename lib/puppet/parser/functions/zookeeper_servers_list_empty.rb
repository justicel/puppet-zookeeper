module Puppet::Parser::Functions
  # Returns boolean true if the Zookeeper Servers List (provided as arg)
  # is an empty hash.
  newfunction(:zookeeper_servers_list_empty, :type => :rvalue) do |args|
    # args[0] = {}
    return args[0].empty?
  end
end
