# frozen_string_literal: true

require "active_support/core_ext/object/blank"

module ActiveSupport
  # = Ordered Options
  #
  # +OrderedOptions+ inherits from +Hash+ and provides dynamic accessor methods.
  #
  # With a +Hash+, key-value pairs are typically managed like this:
  #
  #   h = {}
  #   h[:boy] = 'John'
  #   h[:girl] = 'Mary'
  #   h[:boy]  # => 'John'
  #   h[:girl] # => 'Mary'
  #   h[:dog]  # => nil
  #
  # Using +OrderedOptions+, the above code can be written as:
  #
  #   h = ActiveSupport::OrderedOptions.new
  #   h.boy = 'John'
  #   h.girl = 'Mary'
  #   h.boy  # => 'John'
  #   h.girl # => 'Mary'
  #   h.dog  # => nil
  #
  # To raise an exception when the value is blank, append a
  # bang to the key name, like:
  #
  #   h.dog! # => raises KeyError: :dog is blank
  #
  class OrderedOptions < Hash
    alias_method :_get, :[] # preserve the original #[] method
    protected :_get # make it protected

    def []=(key, value)
      super(key.to_sym, value)
    end

    def [](key)
      super(key.to_sym)
    end

    def dig(key, *identifiers)
      super(key.to_sym, *identifiers)
    end

    def method_missing(name, *args)
      name_string = +name.to_s
      if name_string.chomp!("=")
        self[name_string] = args.first
      else
        bangs = name_string.chomp!("!")

        if bangs
          self[name_string].presence || raise(KeyError.new(":#{name_string} is blank"))
        else
          self[name_string]
        end
      end
    end

    def respond_to_missing?(name, include_private)
      true
    end

    def extractable_options?
      true
    end

    def inspect
      "#<#{self.class.name} #{super}>"
    end
  end

  # = Inheritable Options
  #
  # +InheritableOptions+ provides a constructor to build an OrderedOptions
  # hash inherited from another hash.
  #
  # Use this if you already have some hash and you want to create a new one based on it.
  #
  #   h = ActiveSupport::InheritableOptions.new({ girl: 'Mary', boy: 'John' })
  #   h.girl # => 'Mary'
  #   h.boy  # => 'John'
  #
  # If the existing hash has string keys, call Hash#symbolize_keys on it.
  #
  #   h = ActiveSupport::InheritableOptions.new({ 'girl' => 'Mary', 'boy' => 'John' }.symbolize_keys)
  #   h.girl # => 'Mary'
  #   h.boy  # => 'John'
  class InheritableOptions < OrderedOptions
    def initialize(parent = nil)
      @parent = parent
      if @parent.kind_of?(OrderedOptions)
        # use the faster _get when dealing with OrderedOptions
        super() { |h, k| @parent._get(k) }
      elsif @parent
        super() { |h, k| @parent[k] }
      else
        super()
        @parent = {}
      end
    end

    def to_h
      @parent.dup.merge(self)
    end

    def ==(other)
      to_h == other.to_h
    end

    def inspect
      "#<#{self.class.name} #{to_h.inspect}>"
    end

    def inheritable_copy
      self.class.new(self)
    end
  end
end
