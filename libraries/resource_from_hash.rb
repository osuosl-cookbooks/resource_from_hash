require 'poise'

def string_symbol(s)
  s.is_a?(String) ? s.to_sym : s.to_s
end

def indifferent_access(hash, key)
  return hash[key] if hash.key?(key)
  key = string_symbol(key)
  return hash[key] if hash.key?(key)
  nil
end

class Chef
  class Resource
    class ResourceFromHash < Resource
      include Poise
      provides(:resource_from_hash)
      require 'chef/mixin/convert_to_class_name'

      actions(:do, :log)
      attribute(:hash, kind_of: Hash, default: {})
      attribute(:res, kind_of: Class, default: lazy do
        eval 'Chef::Resource::' +
          convert_to_class_name(indifferent_access(hash, 'resource'))
      end)
    end
  end

  class Provider
    class ResourceFromHash < Provider
      include Poise
      provides(:resource_from_hash)

      def action_log
        Chef::Log.info "Logging resource hash #{new_resource.name} "\
          "with the following attributes: #{new_resource.hash}"
      end

      # rubocop:disable MethodLength
      def action_do
        # Here be dragons..
        prefix = "Proc.new {\n"
        attributes = indifferent_access(new_resource.hash, 'attributes').to_a
        body = attributes.collect do |a|
          "#{a.first}(#{a.last.inspect})"
        end.join("\n")
        suffix = '}'

        # rubocop:disable Lint/UselessAssignment
        block = eval(prefix + body + suffix)
        name = indifferent_access(new_resource.hash, 'name').inspect
        resource = string_symbol(new_resource.res.resource_name) +
                   "(#{name},&block)"
        # rubocop:enable Lint/UselessAssignment
        eval(resource)
      end
      # rubocop:enable MethodLength
    end
  end
end
