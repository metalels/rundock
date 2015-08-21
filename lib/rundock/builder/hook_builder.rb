require 'yaml'

module Rundock
  module Builder
    class HookBuilder < Base
      HookStructureError = Class.new(NotImplementedError)

      def build(enables)
        if enables.blank?
          return []
        elsif @options[:hooks] && FileTest.exist?(@options[:hooks])
          hooks_file = @options[:hooks]
        else
          return []
        end

        build_from_file(hooks_file, enables)
      end

      def build_from_attributes(attributes)
        return [] unless attributes.key?(:enable_hooks)
        build_from_file(attributes[:hooks], attributes[:enable_hooks])
      end

      private

      def build_from_file(file, enables)
        hooks = []
        allow_all = enables.include?('all')

        File.open(file) do |f|
          YAML.load_documents(f) do |y|
            y.each do |k, v|
              raise HookStructureError if !v.is_a?(Hash) || !v.key?('hook_type')
              next if !allow_all && enables.include?(k)
              hook = Rundock::HookFactory.instance(v['hook_type']).create(k, v.deep_symbolize_keys)
              hooks << hook
            end
          end
        end

        hooks
      end
    end
  end
end