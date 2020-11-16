# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "dfe_wizard"

shared_context "with wizard store" do
  let(:backingstore) { { "name" => "Joe", "age" => 35 } }
  let(:wizardstore) { DFEWizard::Store.new backingstore }
end

shared_context "with wizard step" do
  include_context "with wizard store"
  subject { instance }

  let(:attributes) { {} }
  let(:instance) { described_class.new nil, wizardstore, attributes }
end

shared_examples "a wizard step" do
  it { expect(subject.class).to respond_to :key }
  it { is_expected.to respond_to :save }
end

class TestWizard < DFEWizard::Base
  class Name < DFEWizard::Step
    attribute :name
    validates :name, presence: true
  end

  class Age < DFEWizard::Step
    attribute :age, :integer
    validates :age, presence: true
  end

  class Postcode < DFEWizard::Step
    attribute :postcode
    validates :postcode, presence: true
  end

  self.steps = [Name, Age, Postcode].freeze
end
