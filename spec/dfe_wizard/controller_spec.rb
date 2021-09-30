require "rails_helper"

describe "EventStepsController", type: :request do
  let(:readable_event_id) { "123" }
  let(:model) { Events::Steps::ContactDetails }
  let(:step_path) { event_step_path readable_event_id, model.key }

  describe "#index" do
    subject { response }

    before { get event_steps_path("123", query: "param") }

    it { is_expected.to redirect_to(event_step_path("123", { id: :personal_details, query: "param" })) }
  end

  describe "#show" do
    subject { response }

    before { get step_path }

    it { is_expected.to have_http_status :success }

  end

  describe "#update" do
    subject do
      patch step_path, params: { key => details_params }
      response
    end

    let(:key) { model.model_name.param_key }

    context "with valid data" do
      let(:details_params) { { address_telephone: "valid" } }

      it do
        redirect_to \
            event_step_path(readable_event_id, "personal_details")
      end
    end

    context "with invalid data" do
      let(:details_params) { { address_telephone: "" } }

      it { is_expected.to have_http_status :success }
    end

    context "with no data" do
      let(:details_params) { {} }

      it { is_expected.to have_http_status :success }
    end

    context "with last step" do
      let(:model) { Events::Steps::ContactDetails }

      context "when all valid" do
        before do
          allow_any_instance_of(Events::Steps::PersonalDetails).to \
              receive(:valid?).and_return true

          allow_any_instance_of(Events::Steps::ContactDetails).to \
              receive(:valid?).and_return true
        end

        let(:details_params) { { "address_telephone": "valid" } }

        it { is_expected.to redirect_to completed_event_steps_path(readable_event_id) }
      end

      context "when invalid steps" do
        let(:details_params) { { "address_telephone": "valid" } }

        it do
          is_expected.to redirect_to \
            event_step_path(readable_event_id, "personal_details")
        end
      end
    end
  end

  describe "#completed" do
    subject do
      get completed_event_steps_path(readable_event_id)
      # pry
      response
    end

    it { is_expected.to have_http_status :success }
  end

  describe "#resend_verification" do
    let(:too_many_requests_error) { GetIntoTeachingApiClient::ApiError.new(code: 429) }
    let(:bad_request_error) { GetIntoTeachingApiClient::ApiError.new(code: 400) }

    it "redirects to the authentication_path with verification_resent: true" do
      allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to \
          receive(:create_candidate_access_token)
      get resend_verification_event_steps_path(readable_event_id, redirect_path: "redirect/path")
      expect(response).to redirect_to controller.send(:authenticate_path, verification_resent: true)
    end

    context "when the API returns 429 too many requests" do
      before do
        allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to \
          receive(:create_candidate_access_token).and_raise(too_many_requests_error)
      end

      it "re-raises the error" do
        expect { get resend_verification_event_steps_path(readable_event_id, redirect_path: "redirect/path") }.to raise_error too_many_requests_error
      end
    end

    context "when the API returns 400 bad request" do
      subject! do
        allow_any_instance_of(GetIntoTeachingApiClient::CandidatesApi).to \
          receive(:create_candidate_access_token).and_raise(bad_request_error)
        get resend_verification_event_steps_path(readable_event_id, redirect_path: "redirect/path")
      end

      it { is_expected.to redirect_to(controller.send(:step_path, controller.wizard_class.steps.first.key)) }
    end
  end
end
