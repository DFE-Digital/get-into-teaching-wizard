# frozen_string_literal: true

require "spec_helper"

RSpec.describe DFEWizard do
  describe "VERSION" do
    subject { described_class::VERSION }

    it { is_expected.to eql "0.1.1" }
  end
end
