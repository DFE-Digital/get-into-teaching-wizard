module Events
  class Wizard < ::DFEWizard::Base

    self.steps = [
      Steps::PersonalDetails,
      Steps::ContactDetails,
    ].freeze
  end
end
