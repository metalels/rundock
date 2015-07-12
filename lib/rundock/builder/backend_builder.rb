module Rundock
  module Builder
    class BackendBuilder < Base
      def initialize(options, nodename, node_info)
        super(options)
        @nodename = nodename
        @node_info = node_info
      end

      def build
        opts = {}

        if !@node_info ||
           !@node_info[@nodename]
          @node_info = { @nodename => {} }
        end
        @node_info[@nodename]['ssh_opts'] = {} unless @node_info[@nodename]['ssh_opts']
        is_local = @nodename =~ /localhost|127\.0\.0\.1/

        # replace default ssh options if exists
        @options.keys.select { |o| o =~ /(\w+)_ssh_default$/ }.each do |oo|
          opt = oo.gsub(/_ssh_default/, '')
          # no use default ssh options if local
          # (like docker or localhost with port access host should not use default ssh options)
          @node_info[@nodename]['ssh_opts'][opt] = @options[oo] if !is_local && !@node_info[@nodename]['ssh_opts'][opt]
        end

        if is_local &&
           !@node_info[@nodename]['ssh_opts']['port'] &&
           !@node_info[@nodename]['ssh_opts']['user'] &&
           !@node_info[@nodename]['ssh_opts']['ssh_config']
          backend_type = :local
        else
          backend_type = :ssh
          opts['host'] = @nodename
        end

        opts.merge!(@options)

        # update ssh options for node from node_info
        opts.merge!(@node_info[@nodename]['ssh_opts'])
        # delete trash ssh_options(node[host::ssh_options])
        @node_info[@nodename].delete('ssh_opts')

        # add any attributes for host from node_info
        opts.merge!(@node_info[@nodename])
        Backend.create(backend_type, opts)
      end
    end
  end
end