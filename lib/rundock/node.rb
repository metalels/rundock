require 'rundock'

module Rundock
  class Node
    attr_reader :name
    attr_reader :operations
    attr_reader :backend

    def initialize(name, backend)
      @name = name
      @backend = backend
    end

    def add_operation(ope)
      @operations = [] unless @operations
      @operations << ope
    end

    def run
      Logger.debug("run name: #{@name}")
      if @operations.blank?
        Logger.warn("no operation running: #{@name}")
        return
      end
      @operations.each do |ope|
        Logger.debug("operation type: #{ope.class}")
        ope.run(@backend, ope.attributes)
      end
    end
  end
end
