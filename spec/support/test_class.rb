# (c) 2018 Ribose Inc.
#
#

module TestClassInstantiation
  def instantiate_test_class(name, &block)
    cl = Class.new
    cl.class_eval(&block) if block_given?
    stub_const name, cl
    cl
  end
end
