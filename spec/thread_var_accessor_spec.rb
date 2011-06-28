# (c) 2018 Ribose Inc.
#
#

require File.expand_path('../spec_helper',  __FILE__)

describe ThreadVarAccessor do
  def create_test_class accessor = :test
    tc = Class.new
    tc.class_eval {
      include ThreadVarAccessor
      thread_var_accessor accessor
    }
    tc
  end

  before do
    @test_class = create_test_class()
  end

  it "test tva" do
    tc = @test_class
    tc.test.should be_nil
    tc.bind_test :foo
    begin
      tc.test.should eql(:foo)
      tc.bind_test :bar
      begin
        tc.test.should eql(:bar)
        tc.test = nil
        tc.test.should be_nil
      ensure
        tc.unbind_test
      end
      tc.test.should eql(:foo)
    ensure
      tc.unbind_test
    end
    tc.test.should be_nil
  end

  it "test binding" do
    tc = @test_class
    tc.binding_test(:foo) {
      tc.test.should eql(:foo)
      tc.binding_test(:bar) {
        tc.test.should eql(:bar)
        tc.test = nil
        tc.test.should be_nil
      }
      tc.test.should eql(:foo)
    }
    tc.test.should be_nil
  end

  it "test independence" do
    tc = @test_class
    tc2 = create_test_class()
    tc.binding_test(:foo) {
      tc.test.should eql(:foo)
      tc2.test.should be_nil
      tc2.binding_test(:bar) {
        tc.test.should eql(:foo)
        tc2.test.should eql(:bar)
      }
    }
  end

  it "test binding many" do
    tc = @test_class
    tc.module_eval do
      class << self
        attr :test2, true
      end
      attr :test3, true
    end

    ti = tc.new

    tc.test = :initial
    tc.test2 = :initial2
    ti.test3 = :initial3


    [tc.test, tc.test2, ti.test3].should eql([:initial, :initial2, :initial3])

    ThreadVarAccessor.binding_many([tc, :test, :bound1],
                                   [ti, :test3],
                                   [tc, :test2, :bound2]) do
      tc.test.should eql(:bound1)
      ti.test3.should be_nil
      tc.test2.should eql(:bound2)
    end

    [tc.test, tc.test2, ti.test3].should eql([:initial, :initial2, :initial3])
  end
end

