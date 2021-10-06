module Events
  class Wizard < ::DFEWizard::Base
    self.steps = [
      Steps::PersonalDetails,
      DFEWizard::Steps::Authenticate,
      Steps::ContactDetails,
    ].freeze
  end
end
