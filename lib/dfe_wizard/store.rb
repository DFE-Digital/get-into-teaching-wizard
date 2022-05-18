module DFEWizard
  class Store
    class InvalidBackingStore < RuntimeError; end

    delegate :keys, :to_h, :to_hash, to: :combined_data
    delegate :keys, to: :@new_data, prefix: :new

    def initialize(new_data, preexisting_data)
      stores = [new_data, preexisting_data]
      raise InvalidBackingStore unless stores.all? { |s| s.respond_to?(:[]=) }

      @new_data = new_data
      @preexisting_data = preexisting_data
    end

    def [](key)
      combined_data[key.to_s]
    end

    def []=(key, value)
      @new_data[key.to_s] = value
    end

    def preexisting(key)
      @preexisting_data[key.to_s]
    end

    def fetch(*keys, source: :both)
      array_of_keys = Array.wrap(keys).flatten.map(&:to_s)
      Hash[array_of_keys.zip].merge(store(source).slice(*array_of_keys))
    end

    def persist(attributes)
      @new_data.merge!(attributes.stringify_keys)

      true
    end

    def persist_preexisting(attributes)
      @preexisting_data.merge!(attributes.stringify_keys)

      true
    end

    def purge!
      @new_data.clear
      @preexisting_data.clear
    end

    # purges the preexisting data but leaves a subset of new data
    # that might be used on or after the completion page
    def prune!(leave: [])
      @new_data.slice!(*Array.wrap(leave))
      @preexisting_data.clear
    end

  private

    def store(source)
      case source
      when :new then @new_data
      when :preexisting then @preexisting_data
      else combined_data
      end
    end

    def combined_data
      @preexisting_data.merge(@new_data)
    end
  end
end
