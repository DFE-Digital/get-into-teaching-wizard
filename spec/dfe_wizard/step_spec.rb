# frozen_string_literal: true

require "spec_helper"

describe DFEWizard::Step do
  include_context "with wizard store"

  subject { first_step.new nil, wizardstore, attributes }

  let(:first_step) do
    Class.new(described_class) do
      attribute :name
      attribute :age, :integer
      validates :name, presence: true

      # Needed because we're using an anonymous class
      def self.name
        "FirstStep"
      end
    end
  end

  let(:attributes) { {} }

  describe ".key" do
    it { expect(described_class.key).to eql "step" }
    it { expect(first_step.key).to eql "first_step" }
  end

  describe ".title" do
    it { expect(described_class.title).to eql "Step" }
    it { expect(first_step.title).to eql "First step" }
  end

  describe ".new" do
    let(:attributes) { { age: "20" } }

    it { is_expected.to be_instance_of first_step }
    it { is_expected.to have_attributes key: "first_step" }
    it { is_expected.to have_attributes id: "first_step" }
    it { is_expected.to have_attributes persisted?: true }
    it { is_expected.to have_attributes name: "Joe" }
    it { is_expected.to have_attributes age: 20 }
    it { is_expected.to have_attributes skipped?: false }
  end

  describe "#can_proceed" do
    it { is_expected.to be_can_proceed }
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

  describe "#export" do
    subject { instance.export }

    let(:backingstore) { { "name" => "Joe" } }
    let(:instance) { first_step.new nil, wizardstore, age: 35 }

    it { is_expected.to include "name" => "Joe" }
    it { is_expected.to include "age" => nil } # should only export persisted data
  end
end
