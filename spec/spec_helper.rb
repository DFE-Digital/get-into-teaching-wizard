# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "dfe_wizard"

shared_context "with wizard store" do
  let(:backingstore) { { "name" => "Joe", "age" => 35 } }
  let(:crm_backingstore) { {} }
  let(:wizardstore) { DFEWizard::Store.new backingstore, crm_backingstore }
end

shared_context "with wizard step" do
  subject { instance }

  include_context "with wizard store"

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

  # To simulate two steps writing to the same attribute.
  class OtherAge < DFEWizard::Step
    attribute :age, :integer
    validates :age, presence: false
  end

  class Age < DFEWizard::Step
    attribute :age, :integer
    validates :age, presence: true
  end

  class Postcode < DFEWizard::Step
    attribute :postcode
    validates :postcode, presence: true
  end

  self.steps = [Name, OtherAge, Age, Postcode].freeze
end
