module Puppet::Parser::Functions
  newfunction(:pt_delete_values, :type => :rvalue, :doc => <<-EOS
Deletes all instances of a given value from a hash.

*Examples:*

    pt_delete_values({'a'=>'A','b'=>'B','c'=>'C','B'=>'D'}, 'B')

Would return: {'a'=>'A','c'=>'C','B'=>'D'}

      EOS
    ) do |arguments|

    raise(Puppet::ParseError,
          "pt_delete_values(): Wrong number of arguments given " +
          "(#{arguments.size} of 2)") if arguments.size != 2

    hash = arguments[0]
    item = arguments[1]

    if not hash.is_a?(Hash)
      raise(TypeError, "pt_delete_values(): First argument must be a Hash. " + \
                       "Given an" " argument of class #{hash.class}.") 
    end
    hash.delete_if { |key, val| item == val }
  end
end