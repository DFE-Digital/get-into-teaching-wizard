module Events
  module Steps
    class ContactDetails < ::GITWizard::Step
      attribute :address_telephone

      validates :address_telephone, presence: true, length: { maximum: 5 }
    end
  end
end
