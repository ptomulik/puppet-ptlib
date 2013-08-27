# ptomulik-ptlib #

[![Build Status](https://travis-ci.org/ptomulik/puppet-ptlib.png?branch=master)](https://travis-ci.org/ptomulik/puppet-ptlib)

Utility functions for puppet modules' developers. 

# Functions #

pt\_delete\_undef\_values
-------------------------
Deletes all instances of the undef value from an array or hash.

*Examples:*
    
    $hash = pt_delete_undef_values({a=>'A', b=>'', c=>undef, d => false})

Would return: `{a => 'A', b => '', d => false}`

    $array = pt_delete_undef_values(['A','',undef,false])

Would return: `['A','',false]`

- *Type*: rvalue

pt\_delete\_values
------------------
Deletes all instances of a given value from a hash.

*Examples:*

    pt_delete_values({'a'=>'A','b'=>'B','c'=>'C','B'=>'D'}, 'B')

Would return: `{'a'=>'A','c'=>'C','B'=>'D'}`

- *Type*: rvalue

pt\_getparamdefault
-------------------

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

- *Type*: rvalue
