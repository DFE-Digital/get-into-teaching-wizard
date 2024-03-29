module Events
  class Wizard < ::GITWizard::Base
    self.steps = [
      Steps::PersonalDetails,
      GITWizard::Steps::Authenticate,
      Steps::ContactDetails,
    ].freeze

    def exchange_unverified_request(request)
      super unless find(Steps::PersonalDetails.key).is_walk_in?

      @api ||= GetIntoTeachingApiClient::TeachingEventsApi.new
      @api.exchange_unverified_request_for_teaching_event_add_attendee(request)
    end
  end
end
