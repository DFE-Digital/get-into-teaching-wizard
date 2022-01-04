require "rails_helper"

describe DFEWizard::IssueVerificationCode do
  subject { IssueVerificationCodeStep.new wizard, wizardstore, attributes }

  include_context "with wizard store"

  class IssueVerificationCodeStep < DFEWizard::Step
    include ::DFEWizard::IssueVerificationCode

    attribute :first_name
    attribute :last_name
    attribute :email

    validates :email, presence: true
    validates :first_name, presence: true
    validates :last_name, presence: true
  end

  class StubIssueVerificationCodeWizard < DFEWizard::Base
    self.steps = [IssueVerificationCodeStep].freeze
  end

  let(:attributes) { {} }
  let(:wizard) { StubIssueVerificationCodeWizard.new(wizardstore, "issue_verification_code_step") }

  describe "a step that issues a verification code" do
    subject { IssueVerificationCodeStep.new wizard, wizardstore, attributes }

    describe "#save" do
      before do
        subject.email = "email@address.com"
        subject.first_name = "first"
        subject.last_name = "last"
      end

      let(:request) do
        GetIntoTeachingApiClient::ExistingCandidateRequest.new(
          email: subject.email,
          first_name: subject.first_name,
          last_name: subject.last_name,
          reference: wizard.reference,
        )
      end

      it "purges previous data from the store" do
        allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to receive(:create_candidate_access_token).with(request)
        wizardstore["candidate_id"] = "abc123"
        wizardstore["extra_data"] = "data"
        subject.save
        expect(wizardstore.to_hash).to eq(subject.attributes.merge({
          "authenticate" => true,
          "matchback_failures" => 0,
          "last_matchback_failure_code" => nil,
        }))
      end

      context "when invalid" do
        it "does not call the API" do
          subject.email = nil
          subject.save
          expect_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).not_to receive(:create_candidate_access_token)
          expect(wizardstore["authenticate"]).to be_falsy
          expect(wizardstore["matchback_failures"]).to be_nil
          expect(wizardstore["last_matchback_failure_code"]).to be_nil
        end
      end

      context "when an existing candidate" do
        it "sends verification code and sets authenticate to true" do
          allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to receive(:create_candidate_access_token).with(request)
          subject.save
          expect(wizardstore["authenticate"]).to be_truthy
          expect(wizardstore["matchback_failures"]).to eq(0)
          expect(wizardstore["last_matchback_failure_code"]).to be_nil
        end
      end

      it "will skip the authenticate step for new candidates" do
        expect(Rails.logger).to receive(:info).with("#{IssueVerificationCodeStep} requesting access code")
        expect(Rails.logger).not_to receive(:info).with("#{IssueVerificationCodeStep} potential duplicate (response code 404)")
        allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to receive(:create_candidate_access_token).with(request)
          .and_raise(GetIntoTeachingApiClient::ApiError.new(code: 404))
        subject.save
        expect(wizardstore["authenticate"]).to be_falsy
        expect(wizardstore["matchback_failures"]).to eq(1)
        expect(wizardstore["last_matchback_failure_code"]).to eq(404)
      end

      it "will skip the authenticate step if the CRM is unavailable" do
        expect(Rails.logger).to receive(:info).with("#{IssueVerificationCodeStep} requesting access code")
        expect(Rails.logger).to receive(:info).with("#{IssueVerificationCodeStep} potential duplicate (response code 500)")
        allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to receive(:create_candidate_access_token).with(request)
          .and_raise(GetIntoTeachingApiClient::ApiError.new(code: 500))
        subject.save
        expect(wizardstore["authenticate"]).to be_falsy
        expect(wizardstore["matchback_failures"]).to eq(1)
        expect(wizardstore["last_matchback_failure_code"]).to eq(500)
      end

      context "when the API rate limits the request" do
        let(:too_many_requests_error) { GetIntoTeachingApiClient::ApiError.new(code: 429) }

        it "will re-raise the ApiError (to be rescued by the ApplicationController)" do
          allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to receive(:create_candidate_access_token).with(request)
            .and_raise(too_many_requests_error)
          expect { subject.save }.to raise_error(too_many_requests_error)
          expect(wizardstore["authenticate"]).to be_nil
          expect(wizardstore["matchback_failures"]).to eq(1)
          expect(wizardstore["last_matchback_failure_code"]).to eq(429)
        end
      end

      it "keeps track of how many times a matchback fails" do
        allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to \
          receive(:create_candidate_access_token).with(request)
          .and_raise(GetIntoTeachingApiClient::ApiError.new(code: 404))

        subject.save
        expect(wizardstore["authenticate"]).to be_falsy
        expect(wizardstore["matchback_failures"]).to eq(1)
        expect(wizardstore["last_matchback_failure_code"]).to eq(404)

        allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to \
          receive(:create_candidate_access_token).with(request)
          .and_raise(GetIntoTeachingApiClient::ApiError.new(code: 500))

        subject.save
        expect(wizardstore["matchback_failures"]).to eq(2)
        expect(wizardstore["last_matchback_failure_code"]).to eq(500)

        allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to \
          receive(:create_candidate_access_token).with(request)

        subject.save
        expect(wizardstore["authenticate"]).to be_truthy
        expect(wizardstore["matchback_failures"]).to eq(2)
      end
    end
  end
end
