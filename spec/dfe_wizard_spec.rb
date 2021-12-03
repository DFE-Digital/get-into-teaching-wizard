# frozen_string_literal: true

require "spec_helper"

RSpec.describe DFEWizard do
  describe "VERSION" do
    subject { described_class::VERSION }

    it { is_expected.to eql "1.0.0" }
  end
end
