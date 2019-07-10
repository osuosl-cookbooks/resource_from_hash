resource_name :resource_from_hash

default_action :do

property :new_resource.attrs_hash, Hash, required: true, default: {}

action :do do
  attrs = indifferent_access(new_resource.attrs_hash, 'attributes')
  res_type = indifferent_access(new_resource.attrs_hash, 'resource').to_sym
  res_name = indifferent_access(new_resource.attrs_hash, 'name')

  declare_resource(res_type, res_name) do
    attrs.to_a.each do |attr|
      key, val = attr
      send(key.to_sym, val)
    end
  end
end

action :log do
  Chef::Log.info "Logging resource hash #{name} with the following attributes: #{new_resource.attrs_hash}"
end

action_class do
  def indifferent_access(hash, key)
    return hash[key] if hash.key?(key)
    key = key.is_a?(String) ? key.to_sym : key.to_s
    return hash[key] if hash.key?(key)
    nil
  end
end
