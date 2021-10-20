module Events
  module Steps
    class PersonalDetails < ::DFEWizard::Step
      attribute :email

      validates :email, presence: true
    end
  end
end
