require "rails_helper"

describe "EventStepsController", type: :request do
  include Dummy::Application.routes.url_helpers

  describe "#index" do
    subject { response }

    before { get "/test" }

    it do
      assert_response :ok
    end
  end
end
