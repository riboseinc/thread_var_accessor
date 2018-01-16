# (c) 2018 Ribose Inc.
#
#

require File.expand_path("../spec_helper", __FILE__)

RSpec.describe "ThreadVarAccessor::binding_many" do
  example "multiple variables can be assigned at once with " +
      "ThreadVarAccessor::binding_many" do

    instantiate_test_class "TC" do
      thread_var_accessor :tvar

      class << self
        attr :cvar, true
      end

      attr :ivar, true
    end

    ti = TC.new

    TC.tvar = :initial
    TC.cvar = :initial2
    ti.ivar = :initial3

    expect(TC.tvar).to be(:initial)
    expect(TC.cvar).to be(:initial2)
    expect(ti.ivar).to be(:initial3)

    ThreadVarAccessor.binding_many([TC, :tvar, :bound1],
                                   [ti, :ivar],
                                   [TC, :cvar, :bound2]) do
      expect(TC.tvar).to be(:bound1)
      expect(TC.cvar).to be(:bound2)
      expect(ti.ivar).to be(nil)
    end

    expect(TC.tvar).to be(:initial)
    expect(TC.cvar).to be(:initial2)
    expect(ti.ivar).to be(:initial3)

    catch :loop_breaker do
      loop do
        ThreadVarAccessor.binding_many([TC, :tvar, :bound1],
                                     [ti, :ivar],
                                     [TC, :cvar, :bound2]) do
          expect(TC.tvar).to be(:bound1)
          expect(TC.cvar).to be(:bound2)
          expect(ti.ivar).to be(nil)
          throw :loop_breaker
        end
      end
    end

    expect(TC.tvar).to be(:initial)
    expect(TC.cvar).to be(:initial2)
    expect(ti.ivar).to be(:initial3)
  end
end
