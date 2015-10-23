require 'poise'

def stringSymbol(s)
  if s.class == String
    return s.to_sym
  else
    return s.to_s
  end
end

def indifferentAccess(hash, key)
  if hash.has_key?(key)
    return hash[key]
  else
    key = stringSymbol(key)
    return hash[key] if hash.has_key?(key)
    return nil
  end
end

class Chef
  class Resource::ResourceFromHash < Resource
    include Poise
    provides(:resource_from_hash)
    require 'chef/mixin/convert_to_class_name'

    actions(:do, :log)
    attribute(:hash, kind_of: Hash, default: {})
    attribute(:res, kind_of: Class, default: lazy { eval "Chef::Resource::#{convert_to_class_name(indifferentAccess(hash,'resource'))}" })

  end

  class Provider::ResourceFromHash < Provider
    include Poise
    provides(:resource_from_hash)

    def action_log
      Chef::Log.info "Logging resource hash #{new_resource.name} with the following attributes: #{new_resource.hash}"
    end

    def action_do
      # Here be dragons..
      prefix = "Proc.new {\n"
      body = indifferentAccess(new_resource.hash, 'attributes').to_a.collect{ |a| "#{a.first} #{a.last.inspect}" }.join("\n")
      suffix = "}"

      block = eval(prefix + body + suffix)

      eval("#{new_resource.res.dsl_name}(#{indifferentAccess(new_resource.hash, 'name').inspect},&block)")
    end
  end
end
