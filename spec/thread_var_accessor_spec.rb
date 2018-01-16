# (c) 2018 Ribose Inc.
#
#

require File.expand_path("../spec_helper", __FILE__)

RSpec.describe "#thread_var_accessor" do
  let(:item) { Object.new }

  example "variables can be read, written, and cleared" do
    instantiate_test_class "TC" do
      thread_var_accessor :tvar
    end

    expect(TC.tvar).to be(nil)
    TC.tvar = item
    expect(TC.tvar).to be(item)
    TC.tvar = 7
    expect(TC.tvar).to be(7)
    TC.tvar = nil
    expect(TC.tvar).to be(nil)
  end

  example "many variables can be defined in a class" do
    instantiate_test_class "TC" do
      thread_var_accessor :tvar1, :tvar2
      thread_var_accessor :tvar0
    end

    expect(TC.tvar1).to be(nil)
    expect(TC.tvar2).to be(nil)
    expect(TC.tvar0).to be(nil)
    TC.tvar1 = item
    TC.tvar2 = 7
    TC.tvar0 = :foo
    expect(TC.tvar1).to be(item)
    expect(TC.tvar2).to be(7)
    expect(TC.tvar0).to be(:foo)
  end

  example "stacking values with #bind_* and #unbind_* methods" do
    instantiate_test_class "TC" do
      thread_var_accessor :tvar, :tvar2
    end

    assigning_sequence = [item, 7, nil, :foo]

    TC.tvar = :initial
    TC.tvar2 = :always_the_same

    # Calling #bind shadows previously assigned variable…

    [:initial, *assigning_sequence].each_cons(2) do |v_before, v_to_bind|
      expect(TC.tvar).to be(v_before)
      TC.bind_tvar(v_to_bind)
      expect(TC.tvar).to be(v_to_bind)
      expect(TC.tvar2).to be(:always_the_same)
    end

    # …which can be recovered by calling #unbind.

    [:initial, *assigning_sequence].reverse.each_cons(2) do |_v_now, v_after|
      TC.unbind_tvar
      expect(TC.tvar).to be(v_after)
      expect(TC.tvar2).to be(:always_the_same)
    end

    # However, when stack is empty, #unbind is a NOOP.

    2.times do
      TC.unbind_tvar
      expect(TC.tvar).to be(nil)
      expect(TC.tvar2).to be(:always_the_same)
    end
  end

  example "stacking values with #binding_* method" do
    instantiate_test_class "TC" do
      thread_var_accessor :tvar, :tvar2
    end

    assigning_sequence = [item, 7, nil, :foo]

    TC.tvar = :initial
    TC.tvar2 = :always_the_same

    # Recursively checking

    tests = lambda do |v_before, v_to_bind, *rest|
      expect(TC.tvar).to be(v_before)
      expect(TC.tvar2).to be(:always_the_same)

      TC.binding_tvar(v_to_bind) do
        tests.call(v_to_bind, *rest) unless rest.empty?
      end

      expect(TC.tvar).to be(v_before)
      expect(TC.tvar2).to be(:always_the_same)
    end

    tests.call(:initial, *assigning_sequence)

    # Ensures the value gets reverted despite exception being raised…

    tests_with_exception = lambda do
      TC.binding_tvar(14) do
        expect(TC.tvar).to be(14)
        expect(TC.tvar2).to be(:always_the_same)
        raise "err!"
      end
    end

    expect(&tests_with_exception).to raise_exception(StandardError, "err!")

    expect(TC.tvar).to be(:initial)
    expect(TC.tvar2).to be(:always_the_same)

    # …or other code jumps.

    catch :loop_breaker do
      loop do
        TC.binding_tvar(14) do
          expect(TC.tvar).to be(14)
          expect(TC.tvar2).to be(:always_the_same)
          throw :loop_breaker
          puts "unreachable"
        end
      end
    end

    expect(TC.tvar).to be(:initial)
    expect(TC.tvar2).to be(:always_the_same)
  end

  example "variables are fiber-local" do
    instantiate_test_class "TC" do
      thread_var_accessor :tvar
    end

    TC.tvar = 7

    fiber = Fiber.new do
      expect(TC.tvar).to be(nil)
      TC.tvar = 15
      expect(TC.tvar).to be(15)
    end

    fiber.resume

    expect(TC.tvar).to be(7)
  end

  example "variables defined on different classes are independent from " +
      "each other" do
    instantiate_test_class "TC" do
      thread_var_accessor :tvar
    end
    instantiate_test_class "TC2" do
      thread_var_accessor :tvar
    end

    expect(TC.tvar).to be(nil)
    expect(TC2.tvar).to be(nil)
    TC.tvar = 7
    expect(TC.tvar).to be(7)
    expect(TC2.tvar).to be(nil)
    TC2.binding_tvar(item) do
      expect(TC.tvar).to be(7)
      expect(TC2.tvar).to be(item)
    end
    expect(TC.tvar).to be(7)
    expect(TC2.tvar).to be(nil)
  end
end
