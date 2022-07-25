# frozen_string_literal: true

require "spec_helper"

RSpec.describe GITWizard do
  describe "VERSION" do
    subject { described_class::VERSION }

    it { is_expected.to eql "1.0.1" }
  end
end
