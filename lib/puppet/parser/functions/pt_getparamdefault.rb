module Puppet::Parser::Functions
  newfunction(:pt_getparamdefault, :type => :rvalue, :doc => <<-EOS
Takes a type or resource reference and name of the parameter and returns
default value of parameter for that type/resource (or empty string if default
is not set).

*Examples:*

    package { 'apache2': provider => apt }
    pt_getparamdefault(Package['apache2'], provider)

Would return '' (default provider was not defined).

    Package { provider => aptitude }

    node example.com {
      package { 'apache2': provider => apt }
      pt_getparamdefault(Package['apache2'], provider)
    }

Would return 'aptitude'.

    Package { provider => aptitude }

    node example.com {
      Package { provider => apt }
      package { 'apache2': }
      pt_getparamdefault(Package['apache2'], provider)
    }

Would return 'apt'.

    Package { provider => aptitude }

    node example.com {
      Package { provider => apt }
      pt_getparamdefault(Package, provider)
    }

Would return 'apt'.

    pt_getparamdefault(Foo['bar'], geez)

Would not compile (resource Foo[bar] does not exist)

    pt_getparamdefault(Foo, geez)

Would not compile (type Foo does not exist)

EOS
  ) do |args|

    unless args.length == 2
      raise Puppet::ParseError, ("pt_getparamdefault(): wrong number of arguments (#{args.length} for 2)")
    end

    ref, name = args

    raise(Puppet::ParseError,'getpraamdefault(): parameter name must be a string') unless name.instance_of? String

    return '' if name.empty?

    ref = ref.to_s
    
    if resource = findresource(ref)
      params = resource.scope.lookupdefaults(resource.type)
    elsif ref.match(/^((::){0,1}[A-Z][-\w]*)+$/) and find_resource_type(ref)
      # note, find_resource_type('file') and find_resource_type('File') would
      # find same resource type, but we want this function to work only with
      # capitalized type names. That's why the regular expression is used here. 
      # The expression is duplicated from lexer (CLASSREF token).
      params = lookupdefaults(ref)
    else
      raise(Puppet::ParseError, "'#{ref}' is neither a resource nor a type")
    end
    if param = params[name.intern]
      return param.value
    end

    return ''
  end
end
