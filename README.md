# resource_from_hash-cookbook

This cookbook provides a resource that, given a hash, builds a resource based on that hash.

Although fairly abstract, this resource has a simple set of attributes:

1. `hash`, which accepts a `Hash` of attribute name:value pairs for the new resource.
2. `res`, which is the resource type to make.

For convenience, the resource provides two actions:

* `do`, which acts on the resource
* `log`, which logs the resource and doesn't act

The following is a basic example of usage:

```ruby
data = {
  :resource => "package",
  :name => "git",
  :attributes => {
    :action => :upgrade
  }

}

resource_from_hash "test" do
  hash data
  action :do
end
```

Author:: OSU Open Source Lab (chef@osuosl.org)
