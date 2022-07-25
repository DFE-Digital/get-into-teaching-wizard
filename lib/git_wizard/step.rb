module GITWizard
  class Step
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations::Callbacks

    class << self
      def key
        name.split("::").last.underscore
      end

      def contains_personal_details?
        false
      end

      def title
        key.humanize
      end
    end

    delegate :key, :contains_personal_details?, to: :class
    delegate :title, to: :class
    alias_method :id, :key

    def initialize(wizard, store, attributes = {}, *args)
      @wizard = wizard
      @store = store
      super(*args)
      assign_attributes attributes_from_store
      assign_attributes attributes
    end

    def save
      return false unless valid?

      persist_to_store
    end

    def exit?
      !can_proceed?
    end

    def can_proceed?
      true
    end

    def persisted?
      !id.nil?
    end

    def seen?
      attributes.keys.difference(@store.new_keys).none?
    end

    def required?
      (!seen? || invalid? || !can_proceed?) && !skipped?
    end

    def skipped?
      return false unless optional?

      @store.fetch(attribute_names, source: :preexisting).values.all?(&:present?)
    end

    def optional?
      false
    end

    def other_step(key_or_class)
      key = key_or_class.respond_to?(:key) ? key_or_class.key : key_or_class.to_s
      @wizard.find(key)
    end

    def flash_error(message)
      errors.add(:base, message)
    end

    def export
      attributes = skipped? ? preexisting_attributes : attributes_from_store
      Hash[attributes.keys.zip([])].merge attributes
    end

    def reviewable_answers
      attributes
    end

  private

    def preexisting_attributes
      @store.fetch attributes.keys, source: :preexisting
    end

    def attributes_from_store
      @store.fetch attributes.keys
    end

    def persist_to_store
      @store.persist attributes
    end
  end
end
