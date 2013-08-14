module Puppet::Parser::Functions
  newfunction(:pt_getparamdefault, :type => :rvalue, :doc => <<-EOS
Takes a resource reference and name of the parameter and returns default value
of resource's parameter (or empty string if default is not set).

*Examples:*

    package { 'apache2': provider => apt }
    $prov = pt_getparamdefault(Package['apache2'], provider)

Would result with $prov == '' (default provider was not defined).

    Package { provider => aptitude }

    node example.com {
      package { 'apache2': provider => apt }
      $prov = pt_getparamdefault(Package['apache2'], provider)
    }

Would result with $prov == 'aptitude'.

    Package { provider => aptitude }

    node example.com {
      Package { provider => apt }
      package { 'apache2': }
      $prov = pt_getparamdefault(Package['apache2'], provider)
    }

Would result with $prov == 'apt'.

    pt_getparamdefault(Foo['bar'], geez)

Would not compile (resource Foo[bar] does not exist)

EOS
  ) do |args|

    unless args.length == 2
      raise Puppet::ParseError, ("pt_getparamdefault(): wrong number of arguments (#{args.length} for 2)")
    end

    ref, name = args

    raise(Puppet::ParseError,'getpraamdefault(): parameter name must be a string') unless name.instance_of? String

    return '' if name.empty?

    resource = findresource(ref.to_s)
    raise(Puppet::ParseError, "'#{ref.to_s}' is not a resource") unless resource
    params = resource.scope.lookupdefaults(resource.type)
    if param = params[name.intern]
      return param.value
    end

    return ''
  end
end
