#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe Puppet::Parser::Functions.function(:pt_getparamdefault) do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }
  it "should exist" do
    Puppet::Parser::Functions.function("pt_getparamdefault").should == "function_pt_getparamdefault"
  end
  it "should raise Puppet::ParseError if there is less than 2 arguments" do
    lambda { scope.function_pt_getparamdefault([])}.should( raise_error Puppet::ParseError )
    lambda { scope.function_pt_getparamdefault(['foo'])}.should( raise_error Puppet::ParseError )
  end
  it "should raise Puppet::ParseError if there is more than 2 arguments" do
    lambda { scope.function_pt_getparamdefault(['foo', 'bar', 'geez'])}.should( raise_error Puppet::ParseError )
  end
  
  it "should raise Puppet::ParseError if the second argument is not a string" do
    lambda { scope.function_pt_getparamdefault(['foo', []])}.should( raise_error Puppet::ParseError )
  end

  it "should not compile when reffering non-existent resource" do
    Puppet[:code] = <<-'ENDofPUPPETcode'
        $provider = pt_getparamdefault(Foo['bar'], geez)
    ENDofPUPPETcode
    expect {
      scope.compiler.compile 
    }.to raise_error Puppet::ParseError, /is not a resource/
  end

  it "should return empty string if parameter's default is not set" do
    Puppet[:code] = <<-'ENDofPUPPETcode'
        package { 'apache2': provider => apt }
        $provider = pt_getparamdefault(Package['apache2'], provider)
        if $provider != '' {
          fail ("pt_getparamdefault returned '${provider}' instead of empty string")
        }
    ENDofPUPPETcode
    scope.compiler.compile
  end

  it "should return empty string when referring non-existent parameter" do
    Puppet[:code] = <<-'ENDofPUPPETcode'
        package { 'apache2': }
        $foobar = pt_getparamdefault(Package['apache2'], foobar)
        if $foobar != '' {
          fail ("pt_getparamdefault returned '${foobar}' instead of empty string")
        }
    ENDofPUPPETcode
    scope.compiler.compile
  end

  it "should find parameter's default value from appropriate scope" do
    Puppet[:code] = <<-'ENDofPUPPETcode'
      Package { provider => apt }
      node default {
        Package { provider => aptitude }
        package { 'apache2': }
        $provider = pt_getparamdefault(Package['apache2'], provider)
        if $provider != 'aptitude' {
          fail ("pt_getparamdefault returned '${provider}' instead of 'aptitude'")
        }
      }
      package { 'postfix': }
      $provider = pt_getparamdefault(Package['postfix'], provider)
      if $provider != 'apt' {
        fail ("pt_getparamdefault returned '${provider}' instead of 'apt'")
      }
    ENDofPUPPETcode
    scope.compiler.compile
  end
end
