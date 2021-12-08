require "rails_helper"

describe DFEWizard::Step do
  subject { FirstStep.new wizard, wizardstore, attributes }

  include_context "with wizard store"

  class FirstStep < DFEWizard::Step
    attribute :name
    attribute :age, :integer
    validates :name, presence: true
  end

  class StubSingleStepWizard < DFEWizard::Base
    self.steps = [FirstStep].freeze
  end

  let(:attributes) { {} }
  let(:wizard) { StubSingleStepWizard.new(wizardstore, "first_step") }

  describe ".key" do
    it { expect(described_class.key).to eql "step" }
    it { expect(FirstStep.key).to eql "first_step" }
  end

  describe ".title" do
    it { expect(described_class.title).to eql "Step" }
    it { expect(FirstStep.title).to eql "First step" }
  end

  describe ".contains_personal_details?" do
    it { expect(described_class).not_to be_contains_personal_details }
    it { expect(FirstStep).not_to be_contains_personal_details }
  end

  describe ".new" do
    let(:attributes) { { age: "20" } }

    it { is_expected.to be_instance_of FirstStep }
    it { is_expected.to have_attributes key: "first_step" }
    it { is_expected.to have_attributes id: "first_step" }
    it { is_expected.to have_attributes persisted?: true }
    it { is_expected.to have_attributes name: "Joe" }
    it { is_expected.to have_attributes age: 20 }
    it { is_expected.to have_attributes skipped?: false }
    it { is_expected.to have_attributes optional?: false }
    it { is_expected.to have_attributes can_proceed?: true }
    it { is_expected.to have_attributes exit?: false }
  end

  describe "#other_step" do
    it { expect(subject.other_step(:first_step)).to be_kind_of(FirstStep) }
    it { expect(subject.other_step(FirstStep)).to be_kind_of(FirstStep) }
  end

  describe "#skipped?" do
    context "when optional" do
      before { allow(subject).to receive(:optional?).and_return(true) }

      context "when values for all attributes are present in the preexisting backingstore" do
        before do
          preexisting_backingstore["name"] = "John"
          preexisting_backingstore["age"] = 18
        end

        it { is_expected.to be_skipped }
      end

      context "when values for some attributes are present in the preexisting backingstore" do
        before do
          preexisting_backingstore["name"] = "John"
          preexisting_backingstore["age"] = nil
        end

        it { is_expected.not_to be_skipped }
      end
    end

    context "when not optional" do
      before { allow(subject).to receive(:optional?).and_return(false) }

      context "when values for all attributes are present in the preexisting backingstore" do
        before do
          preexisting_backingstore["name"] = "John"
          preexisting_backingstore["age"] = 18
        end

        it { is_expected.not_to be_skipped }
      end
    end
  end

  describe "#flash_error" do
    before { subject.flash_error("error message") }

    it { expect(subject.errors[:base]).to include("error message") }
  end

  describe "#save" do
    let(:backingstore) { {} }

    context "when valid" do
      let(:attributes) { { name: "Jane" } }
      let!(:result) { subject.save }

      it { expect(result).to be true }
      it { expect(wizardstore[:name]).to eql "Jane" }
    end

    context "when invalid" do
      let(:attributes) { { age: 30 } }
      let!(:result) { subject.save }

      it { expect(result).to be false }
      it { is_expected.to have_attributes errors: hash_including(:name) }
    end
  end

  describe "#reviewable_answers" do
    subject { instance.reviewable_answers }

    let(:backingstore) { { "name" => "Joe" } }
    let(:instance) { FirstStep.new nil, wizardstore, age: 35 }

    it { is_expected.to include "name" => "Joe" }
    it { is_expected.to include "age" => 35 }
  end

  describe "#export" do
    subject { instance.export }

    let(:backingstore) { { "name" => "Joe" } }
    let(:instance) { FirstStep.new nil, wizardstore, age: 35 }

    it { is_expected.to include "name" => "Joe" }
    it { is_expected.to include "age" => nil } # should only export persisted data

    context "when the step is skipped" do
      let(:preexisting_backingstore) { { "name" => "Jimmy" } }

      before { allow(instance).to receive(:skipped?).and_return(true) }

      it { is_expected.to include "name" => "Jimmy" }
      it { is_expected.to include "age" => nil } # should only export persisted data
    end
  end
end
