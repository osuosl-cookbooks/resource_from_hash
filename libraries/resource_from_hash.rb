require 'poise'

def string_symbol(s)
  s.is_a?(String) ? s.to_sym : s.to_s
end

def attr_to_string(a)
  if a.last.is_a?(Hash)
    "#{a.first}(#{a.last.inspect})"
  else
    "#{a.first} #{a.last.inspect}"
  end
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
        eval 'Chef::Resource::'\
          "#{convert_to_class_name(indifferent_access(hash, 'resource'))}"
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

      def action_do
        # Here be dragons..
        prefix = "Proc.new {\n"
        attributes = indifferent_access(new_resource.hash, 'attributes').to_a
        body = attributes.collect { |a| attr_to_string(a) }.join("\n")
        suffix = '}'

        # rubocop:disable Lint/UselessAssignment
        block = eval(prefix + body + suffix)
        resource = "#{new_resource.res.dsl_name}"\
          "(#{indifferent_access(new_resource.hash, 'name').inspect},&block)"
        # rubocop:enable Lint/UselessAssignment
        eval(resource)
      end
    end
  end
end
