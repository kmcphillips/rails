# frozen_string_literal: true

require_relative "abstract_unit"
require "active_support/ordered_options"

class OptionsTest < ActiveSupport::TestCase
  def test_usage
    a = ActiveSupport::Options.new

    assert_nil a[:not_set]

    a[:allow_concurrency] = true
    assert_equal 1, a.size
    assert a[:allow_concurrency]

    a[:allow_concurrency] = false
    assert_equal 1, a.size
    assert_not a[:allow_concurrency]

    a["else_where"] = 56
    assert_equal 2, a.size
    assert_equal 56, a[:else_where]
  end

  def test_looping
    a = ActiveSupport::Options.new

    a[:allow_concurrency] = true
    a["else_where"] = 56

    test = [[:allow_concurrency, true], [:else_where, 56]]

    a.each_with_index do |(key, value), index|
      assert_equal test[index].first, key
      assert_equal test[index].last, value
    end
  end

  def test_string_dig
    a = ActiveSupport::Options.new

    a[:test_key] = 56
    assert_equal 56, a.test_key
    assert_equal 56, a["test_key"]
    assert_equal 56, a.dig(:test_key)
    assert_equal 56, a.dig("test_key")
  end

  def test_nested_dig
    a = ActiveSupport::Options.new

    a[:test_key] = [{ a: 1 }]
    assert_equal 1, a.dig(:test_key, 0, :a)
    assert_nil a.dig(:test_key, 1, :a)
  end

  def test_method_access
    a = ActiveSupport::Options.new

    assert_nil a.not_set

    a.allow_concurrency = true
    assert_equal 1, a.size
    assert a.allow_concurrency

    a.allow_concurrency = false
    assert_equal 1, a.size
    assert_not a.allow_concurrency

    a.else_where = 56
    assert_equal 2, a.size
    assert_equal 56, a.else_where
  end

  def test_inheritable_options_continues_lookup_in_parent
    options = ActiveSupport::Options.new({foo: true})
    assert options.foo
  end

  def test_inheritable_options_can_override_parent
    options = ActiveSupport::Options.new({foo: :bar})
    options[:foo] = :baz

    assert_equal :baz, options.foo
  end

  # def test_inheritable_options_inheritable_copy
  #   original = ActiveSupport::InheritableOptions.new
  #   copy     = original.inheritable_copy

  #   assert copy.kind_of?(original.class)
  #   assert_not_equal copy.object_id, original.object_id
  # end

  def test_introspection
    a = ActiveSupport::Options.new
    assert_respond_to a, :blah
    assert_respond_to a, :blah=
    assert_equal 42, a.method(:blah=).call(42)
    assert_equal 42, a.method(:blah).call
  end

  def test_raises_with_bang
    a = ActiveSupport::Options.new
    a[:foo] = :bar
    assert_respond_to a, :foo!

    assert_nothing_raised { a.foo! }
    assert_equal a.foo, a.foo!

    assert_raises(KeyError) do
      a.foo = nil
      a.foo!
    end
    assert_raises(KeyError) { a.non_existing_key! }
  end

  def test_inheritable_options_with_bang
    a = ActiveSupport::Options.new(foo: :bar)

    assert_nothing_raised { a.foo! }
    assert_equal a.foo, a.foo!

    assert_raises(KeyError) do
      a.foo = nil
      a.foo!
    end
    assert_raises(KeyError) { a.non_existing_key! }
  end

  def test_inspect
    a = ActiveSupport::Options.new
    assert_equal "#<ActiveSupport::Options {}>", a.inspect

    a.foo   = :bar
    a[:baz] = :quz

    assert_equal "#<ActiveSupport::Options {:foo=>:bar, :baz=>:quz}>", a.inspect
  end

  def test_ordered_options_to_h
    object = ActiveSupport::Options.new
    assert_equal({}, object.to_h)
    object.first = "first value"
    object[:second] = "second value"
    object["third"] = "third value"

    assert_equal({ first: "first value", second: "second value", third: "third value" }, object.to_h)
  end

  def test_ordered_options_dup
    object = ActiveSupport::Options.new
    object.first = "first value"
    object[:second] = "second value"
    object["third"] = "third value"

    duplicate = object.dup
    assert_equal object, duplicate
    assert_not_equal object.object_id, duplicate.object_id
  end

  def test_ordered_options_key
    object = ActiveSupport::Options.new
    object.first = "first value"
    object[:second] = "second value"
    object["third"] = "third value"

    assert object.key?(:first)
    assert_not object.key?("first")
    assert object.key?(:second)
    assert_not object.key?("second")
    assert object.key?(:third)
    assert_not object.key?("third")
    assert_not object.key?(:fourth)
  end
end

class SafeOptionsTest < ActiveSupport::TestCase

end
