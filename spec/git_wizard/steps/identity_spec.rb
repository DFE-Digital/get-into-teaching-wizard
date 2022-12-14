require "rails_helper"

describe GITWizard::Steps::Identity, type: :model do
  include_context "with wizard step"
  include_context "sanitize fields", %i[email first_name last_name]

  let(:latest_policy) { GetIntoTeachingApiClient::PrivacyPolicy.new(id: "abc-123", text: "Latest privacy policy") }

  before do
    allow_any_instance_of(GetIntoTeachingApiClient::PrivacyPoliciesApi).to \
      receive(:get_latest_privacy_policy) { latest_policy }
  end

  it_behaves_like "a wizard step"

  it { expect(described_class).to include(::GITWizard::IssueVerificationCode) }

  it { is_expected.to be_contains_personal_details }

  describe "attributes" do
    it { is_expected.to respond_to :first_name }
    it { is_expected.to respond_to :last_name }
    it { is_expected.to respond_to :email }
    it { is_expected.to respond_to :accepted_policy_id }
  end

  describe "first_name" do
    it { is_expected.not_to allow_values(nil, "", "a" * 257).for :first_name }
    it { is_expected.to allow_values("John").for :first_name }
  end

  describe "last_name" do
    it { is_expected.not_to allow_values(nil, "", "a" * 257).for :last_name }
    it { is_expected.to allow_values("John").for :last_name }
  end

  describe "email" do
    it { is_expected.not_to allow_values(nil, "", "a@#{'a' * 101}.com", "some@thing").for :email }
    it { is_expected.to allow_values("test@test.com", "test%.mctest@domain.co.uk").for :email }
  end

  describe "#accepted_policy_id" do
    let(:invalid_id) { "invalid-id" }

    before do
      allow_any_instance_of(GetIntoTeachingApiClient::PrivacyPoliciesApi).to \
        receive(:get_privacy_policy) { latest_policy.id }

      bad_request_error = GetIntoTeachingApiClient::ApiError.new(code: 400)
      allow_any_instance_of(GetIntoTeachingApiClient::PrivacyPoliciesApi).to \
        receive(:get_privacy_policy).with(invalid_id).and_raise(bad_request_error)
    end

    it { is_expected.to allow_value(latest_policy.id).for :accepted_policy_id }
    it { is_expected.not_to allow_value(invalid_id).for :accepted_policy_id }
  end

  describe "#latest_privacy_policy" do
    subject { instance.latest_privacy_policy }

    it { is_expected.to eq(latest_policy) }
  end

  describe "#reviewable_answers" do
    subject { instance.reviewable_answers }

    before do
      instance.first_name = "John"
      instance.last_name = "Doe"
      instance.email = "john@doe.com"
    end

    it { is_expected.to eq({ "name" => "John Doe", "email" => "john@doe.com" }) }
  end

  describe "#export" do
    let(:backingstore) do
      {
        "first_name" => "first",
        "last_name" => "last",
        "email" => "email",
        "accepted_policy_id" => "456",
      }
    end

    subject { instance.export }

    it { is_expected.to include(backingstore) }

    context "when a policy id has not been set" do
      let(:backingstore) { {} }

      it "defaults to the latest policy id" do
        is_expected.to include("accepted_policy_id" => latest_policy.id)
      end
    end
  end
end
