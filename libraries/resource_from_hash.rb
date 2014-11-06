class Chef
  class Resource::ResourceFromHash < Resource
    include Poise
    require 'chef/mixin/convert_to_class_name'

    actions(:do, :log)
    attribute(:hash, kind_of: Hash, default: {})
    attribute(:res, kind_of: Class, default: lazy { eval "Chef::Resource::#{convert_to_class_name(hash['resource'])}" })

  end

  class Provider::ResourceFromHash < Provider
    include Poise

    def action_log
      Chef::Log.info "Logging resource hash #{new_resource.name} with the following attributes: #{new_resource.hash}"
    end

    def action_do
      # Here be dragons..
      prefix = "Proc.new {\n"
      body = new_resource.hash['attributes'].to_a.collect{ |a| "#{a.first} #{a.last.inspect}" }.join("\n")
      suffix = "}"

      block = eval(prefix + body + suffix)

      eval("#{new_resource.res.dsl_name}(#{new_resource.hash['name'].inspect},&block)")
    end
  end
end
