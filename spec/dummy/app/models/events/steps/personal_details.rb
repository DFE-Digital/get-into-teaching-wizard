module Events
  module Steps
    class PersonalDetails < ::GITWizard::Step
      attribute :email

      validates :email, presence: true
    end
  end
end
