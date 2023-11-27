# frozen_string_literal: true

require "active_support/core_ext/hash/keys"
require "active_support/core_ext/object/blank"

module ActiveSupport
  # = Options
  #
  # +Options+ is a specialzation of +Hash+ that provides dynamic accessor methods.
  #
  # Given a +Hash+, key-value pairs are typically managed like this:
  #
  #   options = {}
  #   options[:timeout] = 100
  #   options[:adapter] = "AdapterClass"
  #   options[:timeout] # => 100
  #   options[:adapter] # => "AdapterClass"
  #   options[:message] # => nil
  #
  # Using +Options+, the above code can be written as:
  #
  #   options = ActiveSupport::Options.new
  #   options.timeout = 100
  #   options.adapter = "AdapterClass"
  #   options.timeout # => 100
  #   options.adapter # => "AdapterClass"
  #   options.message # => nil
  #
  # Keys assigned with the dynamic accessor methods are converted to symbols.
  #
  # To raise an exception when the value is blank, append a
  # bang to the method:
  #
  #   options.message! # => raises "KeyError: :message is blank"
  #
  # +Options+ can also be initialized with a hash which will symbolize the keys and initialize the hash with those
  # values. All other hash initialization methods are not supported. For example:
  #
  #   options = ActiveSupport::Options.new(role: "admin", host: "localhost")
  #   options.role # => "admin"
  #   options.host # => "localhost"
  #   options.port # => nil
  #
  class Options < Hash
    def initialize(parent_hash = nil)
      raise ArgumentError, "ActiveSupport::Options.new() may only be initialized with a parent hash." if parent_hash && !parent_hash.is_a?(Hash)
      raise ArgumentError, "ActiveSupport::Options.new() does not accept a block." if block_given?
      super()
      update(parent_hash.symbolize_keys) if parent_hash
    end

    def []=(key, value)
      super(key.to_sym, value)
    end

    def [](key)
      super(key.to_sym)
    end

    def dig(key, *identifiers)
      super(key.to_sym, *identifiers)
    end

    def extractable_options?
      true
    end

    def inspect
      "#<#{self.class.name} #{super}>"
    end

    def method_missing(name, *args)
      name_string = +name.to_s
      if name_string.chomp!("=")
        self[name_string] = args.first
      elsif name_string.chomp!("!")
        self[name_string].presence || raise(KeyError.new(":#{name_string} is blank"))
      else
        self[name_string]
      end
    end

    def respond_to_missing?(name, include_private)
      true
    end
  end

  # = SafeOptions
  #
  # +SafeOptions+ is a specialzation of +ActiveSupport::Options+ that protects dynamic accessor methods from
  # assigning or reading keys that do not already exist on the +SafeOptions+ instance:
  #
  #   options = ActiveSupport::SafeOptions.new(host: "localhost")
  #   options.host # => "localhost"
  #   options.port # => raises "KeyError: :port does not exist"
  #
  # Keys can be assigned through an initialization hash, but also the +[]=+ and +[]+ methods are not protected:
  #
  #   options = ActiveSupport::SafeOptions.new(host: "localhost")
  #   options[:host] # => "localhost"
  #   options[:port] = 3000
  #   options[:port] # => 3000
  #   options[:role] # nil
  #   options.role   # raises "KeyError: :role does not exist"
  #
  class SafeOptions < Options
    def method_missing(name, *args)
      name_string = name.to_s.chomp("=").chomp("!")
      raise KeyError.new(":#{name_string} does not exist") unless key?(name_string)
      super
    end
  end
end
