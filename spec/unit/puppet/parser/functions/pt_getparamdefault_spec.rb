#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe Puppet::Parser::Functions.function(:pt_getparamdefault) do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }
  context "default scope" do

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
      }.to raise_error Puppet::ParseError, /is neither a resource nor a type/
    end

    it "should return empty string if parameters' default is not set" do
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
  end

  [ nil, 'example.com' ].each do |fqdn|
    context "for node #{fqdn.inspect}" do
      let :facts do
        {
          :fqdn => fqdn
        }
      end
      context "with reference to a resource" do
        let(:node) { PuppetlabsSpec::PuppetInternals.node(:name => fqdn) }
        let(:compiler) { PuppetlabsSpec::PuppetInternals.compiler(:node=>node) }
        let(:scope) { PuppetlabsSpec::PuppetInternals.scope(:compiler=>compiler) }
        it "should find parameters' defaults from appropriate scope" do
          Puppet[:code] = <<-'ENDofPUPPETcode'
            file { '/tmp/top': }
            File { content => 'top' }
            $content = pt_getparamdefault(File['/tmp/top'], content)
            if $content != 'top' {
              fail ("pt_getparamdefault returned '${content}' instead of 'top'")
            }
            node default { 
              File { content => 'default' }
              file { '/tmp/default': }
              $default = pt_getparamdefault(File['/tmp/default'], content)
              if $default != 'default' {
                fail ("pt_getparamdefault returned '${default}' instead of 'default'")
              }
              $default_top = pt_getparamdefault(File['/tmp/top'], content)
              if $default_top != 'top' {
                fail ("pt_getparamdefault returned '${default_top}' instead of 'top'")
              }
            }
            node 'example.com' {
              File { content => 'example.com' }
              file { '/tmp/example': }
              $example = pt_getparamdefault(File['/tmp/example'], content)
              if $example != 'example.com' {
                fail ("pt_getparamdefault returned '${content}' instead of 'example.com'")
              }
              $example_top = pt_getparamdefault(File['/tmp/top'], content)
              if $example_top != 'top' {
                fail ("pt_getparamdefault returned '${top}' instead of 'top'")
              }
            }
          ENDofPUPPETcode
          scope.compiler.compile
        end
      end

      context "with reference to a resource of defined type" do
        let(:node) { PuppetlabsSpec::PuppetInternals.node(:name => fqdn) }
        let(:compiler) { PuppetlabsSpec::PuppetInternals.compiler(:node=>node) }
        let(:scope) { PuppetlabsSpec::PuppetInternals.scope(:compiler=>compiler) }
        it "should find parameters' defaults from appropriate scope" do
          Puppet[:code] = <<-'ENDofPUPPETcode'
            define foo($content = undef) { }
            foo { '/tmp/top': }
            Foo { content => 'top' }
            $top = pt_getparamdefault(Foo['/tmp/top'], content)
            if $top != 'top' {
              fail ("pt_getparamdefault returned '${top}' instead of 'top'")
            }
            node default { 
              Foo { content => 'default' }
              foo { '/tmp/default': }
              $default = pt_getparamdefault(Foo['/tmp/default'], content)
              if $default != 'default' {
                fail ("pt_getparamdefault returned '${default}' instead of 'default'")
              }
              $default_top = pt_getparamdefault(Foo['/tmp/top'], content)
              if $default_top != 'top' {
                fail ("pt_getparamdefault returned '${default_top}' instead of 'top'")
              }
            }
            node 'example.com' {
              Foo { content => 'example.com' }
              foo { '/tmp/example': }
              $example = pt_getparamdefault(Foo['/tmp/example'], content)
              if $example != 'example.com' {
                fail ("pt_getparamdefault returned '${content}' instead of 'example.com'")
              }
              $example_top = pt_getparamdefault(Foo['/tmp/top'], content)
              if $example_top != 'top' {
                fail ("pt_getparamdefault returned '${top}' instead of 'top'")
              }
            }
          ENDofPUPPETcode
          scope.compiler.compile
        end
      end

      context "with reference to a builtin resource - from within a defined type" do
        let(:node) { PuppetlabsSpec::PuppetInternals.node(:name => fqdn) }
        let(:compiler) { PuppetlabsSpec::PuppetInternals.compiler(:node=>node) }
        let(:scope) { PuppetlabsSpec::PuppetInternals.scope(:compiler=>compiler) }
        it "should find parameters' defaults from appropriate scope" do
          Puppet[:code] = <<-'ENDofPUPPETcode'
            define check($should) { 
              if !defined(File["/tmp/${should}"]) {
                file { "/tmp/${should}": }
              }
              $is = pt_getparamdefault(File["/tmp/${should}"], content)
              if $is != $should {
                fail ("pt_getparamdefault returned '${is}' instead of '${should}'")
              }
            }
            check { 'top-top': should => 'top' }
            File { content => 'top' }
            node default { 
              check { 'default-default': should => 'default' }
              check { 'default-top': should => 'top' }
              File { content => 'default' }
            }
            node 'example.com' {
              check { 'example-example': should => 'example' }
              check { 'example-top': should => 'top' }
              File { content => 'example' }
            }
          ENDofPUPPETcode
          scope.compiler.compile
        end
      end

      context "with reference to resource of defined type - from within a defined type" do
        let(:node) { PuppetlabsSpec::PuppetInternals.node(:name => fqdn) }
        let(:compiler) { PuppetlabsSpec::PuppetInternals.compiler(:node=>node) }
        let(:scope) { PuppetlabsSpec::PuppetInternals.scope(:compiler=>compiler) }
        it "should find parameters' defaults from appropriate scope" do
          Puppet[:code] = <<-'ENDofPUPPETcode'
            define foo_bar::geez($content = undef) { }
            define check($should) { 
              if !defined(Foo_bar::Geez["/tmp/${should}"]) {
                foo_bar::geez { "/tmp/${should}": }
              }
              $is = pt_getparamdefault(Foo_bar::Geez["/tmp/${should}"], content)
              if $is != $should {
                fail ("pt_getparamdefault returned '${is}' instead of '${should}'")
              }
            }
            check { 'top-top': should => 'top' }
            Foo_bar::Geez { content => 'top' }
            node default { 
              check { 'default-default': should => 'default' }
              check { 'default-top': should => 'top' }
              Foo_bar::Geez { content => 'default' }
            }
            node 'example.com' {
              check { 'example-example': should => 'example' }
              check { 'example-top': should => 'top' }
              Foo_bar::Geez { content => 'example' }
            }
          ENDofPUPPETcode
          scope.compiler.compile
        end
      end

      context "with reference to a built-in type" do
        let(:node) { PuppetlabsSpec::PuppetInternals.node(:name => fqdn) }
        let(:compiler) { PuppetlabsSpec::PuppetInternals.compiler(:node=>node) }
        let(:scope) { PuppetlabsSpec::PuppetInternals.scope(:compiler=>compiler) }
        it "should find parameters' defaults from appropriate scope" do
          Puppet[:code] = <<-'ENDofPUPPETcode'
            File { content => 'top' }
            $top = pt_getparamdefault(File, content)
            if $top != 'top' {
              fail ("pt_getparamdefault returned '${top}' instead of 'top'")
            }
            node default {
              File { content => 'default' }
              $default = pt_getparamdefault(File, content)
              if $default != 'default' {
                fail ("pt_getparamdefault returned '${default}' instead of 'default'")
              }
            }
            node 'example.com' {
              File { content => 'example' }
              $example = pt_getparamdefault(File, content)
              if $example != 'example' {
                fail ("pt_getparamdefault returned '${example}' instead of 'example'")
              }
            }
          ENDofPUPPETcode
          scope.compiler.compile
        end
      end

      context "with reference to a defined type" do
        let(:node) { PuppetlabsSpec::PuppetInternals.node(:name => fqdn) }
        let(:compiler) { PuppetlabsSpec::PuppetInternals.compiler(:node=>node) }
        let(:scope) { PuppetlabsSpec::PuppetInternals.scope(:compiler=>compiler) } 
        it "should find parameters' defaults from appropriate scope" do
          Puppet[:code] = <<-'ENDofPUPPETcode'
            define foo_bar($content = undef) { }
            Foo_bar { content => 'top' }
            $top = pt_getparamdefault(Foo_bar, content)
            if $top != 'top' {
              fail ("pt_getparamdefault returned '${top}' instead of 'top'")
            }
            node default { 
              Foo_bar { content => 'default' }
              $default = pt_getparamdefault(Foo_bar, content)
              if $default != 'default' {
                fail ("pt_getparamdefault returned '${default}' instead of 'default'")
              }
            }
            node 'example.com' {
              Foo_bar { content => 'example.com' }
              $example = pt_getparamdefault(Foo_bar, content)
              if $example != 'example.com' {
                fail ("pt_getparamdefault returned '${content}' instead of 'example.com'")
              }
            }
          ENDofPUPPETcode
          scope.compiler.compile
        end
      end

      context "with reference to builtin type - from within a defined type" do
        let(:node) { PuppetlabsSpec::PuppetInternals.node(:name => fqdn) }
        let(:compiler) { PuppetlabsSpec::PuppetInternals.compiler(:node=>node) }
        let(:scope) { PuppetlabsSpec::PuppetInternals.scope(:compiler=>compiler) }
        it "should find parameters' defaults from appropriate scope" do
          Puppet[:code] = <<-'ENDofPUPPETcode'
            define check($should) { 
              $is = pt_getparamdefault(File, content)
              if $is != $should {
                fail ("pt_getparamdefault returned '${is}' instead of '${should}'")
              }
            }
            check { 'top': should => 'top' }
            File { content => 'top' }
            node default { 
              check { 'default': should => 'default' }
              File { content => 'default' }
            }
            node 'example.com' {
              check { 'example': should => 'example' }
              File { content => 'example' }
            }
          ENDofPUPPETcode
          scope.compiler.compile
        end
      end

      context "with reference to a defined type - from within a defined type" do
        let(:node) { PuppetlabsSpec::PuppetInternals.node(:name => fqdn) }
        let(:compiler) { PuppetlabsSpec::PuppetInternals.compiler(:node=>node) }
        let(:scope) { PuppetlabsSpec::PuppetInternals.scope(:compiler=>compiler) }
        it "should find parameters' defaults from appropriate scope" do
          Puppet[:code] = <<-'ENDofPUPPETcode'
            define foo_bar::geez($content = undef) { }
            define check($should) { 
              $is = pt_getparamdefault(Foo_bar::Geez, content)
              if $is != $should {
                fail ("pt_getparamdefault returned '${is}' instead of '${should}'")
              }
            }
            check { 'top': should => 'top' }
            Foo_bar::Geez { content => 'top' }
            node default { 
              check { 'default': should => 'default' }
              Foo_bar::Geez { content => 'default' }
            }
            node 'example.com' {
              check { 'example': should => 'example' }
              Foo_bar::Geez { content => 'example' }
            }
          ENDofPUPPETcode
          scope.compiler.compile
        end
      end

    end
  end
end
