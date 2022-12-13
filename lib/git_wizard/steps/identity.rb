module GITWizard
  module Steps
    class Identity < ::GITWizard::Step
      include ::GITWizard::IssueVerificationCode

      attribute :first_name
      attribute :last_name
      attribute :email
      attribute :accepted_policy_id

      validates :first_name, presence: true, length: { maximum: 256 }
      validates :last_name, presence: true, length: { maximum: 256 }
      validates :email, presence: true, email_format: true
      validates :accepted_policy_id, policy: true

      before_validation :sanitize_input

      def self.contains_personal_details?
        true
      end

      def export
        super.tap do |data|
          data["accepted_policy_id"] ||= latest_privacy_policy.id
        end
      end

      def reviewable_answers
        super.tap { |answers|
          answers["name"] = "#{answers['first_name']} #{answers['last_name']}"
        }.without(%w[first_name last_name accepted_policy_id])
      end

      def latest_privacy_policy
        @latest_privacy_policy ||= GetIntoTeachingApiClient::PrivacyPoliciesApi.new.get_latest_privacy_policy
      end

    private

      def sanitize_input
        self.email = email.to_s.strip.presence
        self.first_name = first_name.to_s.strip.presence
        self.last_name = last_name.to_s.strip.presence
      end
    end
  end
end
