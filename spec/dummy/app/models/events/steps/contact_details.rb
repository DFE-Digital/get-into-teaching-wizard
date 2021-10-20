module Events
  module Steps
    class ContactDetails < ::DFEWizard::Step
      attribute :address_telephone

      validates :address_telephone, presence: true, length: { maximum: 5 }
    end
  end
end
