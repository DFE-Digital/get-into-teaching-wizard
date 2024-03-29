require "action_controller/railtie"

require "rspec/rails"
require "active_record"

require File.expand_path("dummy/config/application", __dir__)

require "git_wizard"

shared_context "with wizard store" do
  let(:backingstore) { { "name" => "Joe", "age" => 35 } }
  let(:preexisting_backingstore) { {} }
  let(:wizardstore) { GITWizard::Store.new backingstore, preexisting_backingstore }
end

shared_context "with wizard step" do
  include_context "with wizard store"
  subject { instance }

  let(:attributes) { {} }
  let(:wizard) { TestWizard.new(wizardstore, TestWizard::Name.key) }
  let(:instance) do
    described_class.new wizard, wizardstore, attributes
  end
end

shared_examples "a wizard step" do
  it { expect(subject.class).to respond_to :key }
  it { is_expected.to respond_to :save }
end

class TestWizard < GITWizard::Base
  class Name < GITWizard::Step
    attribute :name
    validates :name, presence: true
  end

  # To simulate two steps writing to the same attribute.
  class OtherAge < GITWizard::Step
    attribute :age, :integer
    validates :age, presence: false
  end

  class Age < GITWizard::Step
    attribute :age, :integer
    validates :age, presence: true
    validates :age, numericality: { greater_than: 0 }
  end

  class Postcode < GITWizard::Step
    attribute :postcode
    validates :postcode, presence: true
  end

  self.steps = [Name, OtherAge, Age, Postcode].freeze

  def matchback_attributes
    %i[candidate_id qualification_id adviser_status_id].freeze
  end
end
