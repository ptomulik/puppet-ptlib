#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe Puppet::Parser::Functions.function(:pt_delete_undef_values) do 
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    Puppet::Parser::Functions.function("pt_delete_undef_values").should == "function_pt_delete_undef_values"
  end

  it "should raise a ParseError if there is less than 1 argument" do
    lambda { scope.function_pt_delete_undef_values([]) }.should( raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if the argument is not Array nor Hash" do
    lambda { scope.function_pt_delete_undef_values(['']) }.should( raise_error(Puppet::ParseError))
    lambda { scope.function_pt_delete_undef_values([nil]) }.should( raise_error(Puppet::ParseError))
  end

  it "should delete :undef values from Array" do
    result = scope.function_pt_delete_undef_values([['a',:undef,'c']])
    result.should(eq(['a','c']))
  end

  it "should delete :undef values from Hash" do
    result = scope.function_pt_delete_undef_values([{'a'=>'A', 'b' => :undef, 'c' => 'C'}])
    result.should(eq({'a'=>'A','c'=>'C'}))
  end
end
