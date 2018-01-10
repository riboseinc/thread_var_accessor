# (c) 2018 Ribose Inc.
#
#

require File.expand_path("../spec_helper", __FILE__)

RSpec.describe ThreadVarAccessor do
  def create_test_class(accessor = :test)
    tc = Class.new
    tc.class_eval do
      include ThreadVarAccessor
      thread_var_accessor accessor
    end
    tc
  end

  before do
    @test_class = create_test_class
  end

  it "test tva" do
    tc = @test_class
    expect(tc.test).to be_nil
    tc.bind_test :foo
    begin
      expect(tc.test).to eql(:foo)
      tc.bind_test :bar
      begin
        expect(tc.test).to eql(:bar)
        tc.test = nil
        expect(tc.test).to be_nil
      ensure
        tc.unbind_test
      end
      expect(tc.test).to eql(:foo)
    ensure
      tc.unbind_test
    end
    expect(tc.test).to be_nil
  end

  it "test binding" do
    tc = @test_class
    tc.binding_test(:foo) do
      expect(tc.test).to eql(:foo)
      tc.binding_test(:bar) do
        expect(tc.test).to eql(:bar)
        tc.test = nil
        expect(tc.test).to be_nil
      end
      expect(tc.test).to eql(:foo)
    end
    expect(tc.test).to be_nil
  end

  it "test independence" do
    tc = @test_class
    tc2 = create_test_class
    tc.binding_test(:foo) do
      expect(tc.test).to eql(:foo)
      expect(tc2.test).to be_nil
      tc2.binding_test(:bar) do
        expect(tc.test).to eql(:foo)
        expect(tc2.test).to eql(:bar)
      end
    end
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

    expect([tc.test, tc.test2, ti.test3]).to eql(%i[initial initial2 initial3])

    ThreadVarAccessor.binding_many([tc, :test, :bound1],
                                   [ti, :test3],
                                   [tc, :test2, :bound2]) do
      expect(tc.test).to eql(:bound1)
      expect(ti.test3).to be_nil
      expect(tc.test2).to eql(:bound2)
    end

    expect([tc.test, tc.test2, ti.test3]).to eql(%i[initial initial2 initial3])
  end
end
