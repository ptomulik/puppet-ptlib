# ptomulik-ptlib #

[![Build Status](https://travis-ci.org/ptomulik/ptomulik-ptlib.png?branch=master)](https://travis-ci.org/ptomulik/ptomulik-ptlib)

This module provides a utility library of functions for developing Puppet
Modules. 

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

Takes a resource reference and name of the parameter and returns default value
of resource's parameter (or empty string if default is not set).

*Examples:*

    package { 'apache2': provider => apt }
    $prov = pt_getparamdefault(Package['apache2'], provider)

Would result with `$prov == ''` (default provider was not defined).

    Package { provider => aptitude }

    node example.com {
      package { 'apache2': provider => apt }
      $prov = pt_getparamdefault(Package['apache2'], provider)
    }

Would result with `$prov == 'aptitude'`.

    Package { provider => aptitude }

    node example.com {
      Package { provider => apt }
      package { 'apache2': }
      $prov = pt_getparamdefault(Package['apache2'], provider)
    }

Would result with `$prov == 'apt'`. 

    pt_getparamdefault(Foo['bar'], geez)

Would not compile (resource `Foo[bar]` does not exist)

- *Type*: rvalue
