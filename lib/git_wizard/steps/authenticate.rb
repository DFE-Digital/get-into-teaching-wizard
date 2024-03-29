module GITWizard
  module Steps
    class Authenticate < ::GITWizard::Step
      include ActiveModel::Dirty

      INVALID_MESSAGE = "The verification code should be 6 digits".freeze
      BLANK_MESSAGE = "Enter the verification code sent to your email address".freeze
      WRONG_CODE_MESSAGE = "Please enter the latest verification code sent to your email address".freeze

      IDENTITY_ATTRS = %i[email first_name last_name date_of_birth].freeze

      attribute :timed_one_time_password

      validates :timed_one_time_password, presence: { message: BLANK_MESSAGE }, length: { is: 6, message: INVALID_MESSAGE },
                                          format: { with: /\A[0-9]*\z/, message: INVALID_MESSAGE }
      validate :timed_one_time_password_is_correct, if: :perform_api_check?

      before_validation if: :timed_one_time_password do
        self.timed_one_time_password = timed_one_time_password.to_s.strip
      end

      def skipped?
        @store["authenticate"] != true
      end

      def export
        {}
      end

      def reviewable_answers
        {}
      end

      def candidate_identity_data
        @store.fetch(IDENTITY_ATTRS).compact
      end

    private

      def perform_api_check?
        timed_one_time_password_valid? && !@wizard.access_token_used?
      end

      def timed_one_time_password_valid?
        self.class.validators_on(:timed_one_time_password).each do |validator|
          validator.validate_each(self, :timed_one_time_password, timed_one_time_password)
        end
        errors.none?
      end

      def timed_one_time_password_is_correct
        params = candidate_identity_data.merge({ reference: @wizard.reference })
        request = GetIntoTeachingApiClient::ExistingCandidateRequest.new(params)
        if timed_one_time_password_changed?
          clear_attribute_changes(%i[timed_one_time_password])
          @wizard.process_access_token(timed_one_time_password, request)
        end
      rescue GetIntoTeachingApiClient::ApiError
        errors.add(:timed_one_time_password, WRONG_CODE_MESSAGE)
      end
    end
  end
end
