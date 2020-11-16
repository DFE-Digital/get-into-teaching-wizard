# frozen_string_literal: true

require "spec_helper"

describe DFEWizard::Store do
  subject { instance }

  let(:backingstore) do
    { "first_name" => "Joe", "age" => 20, "region" => "Manchester" }
  end

  let(:instance) { described_class.new backingstore }

  describe ".new" do
    context "with valid source data" do
      it { is_expected.to be_instance_of(described_class) }
      it { is_expected.to have_attributes data: backingstore }
      it { is_expected.to respond_to :[] }
      it { is_expected.to respond_to :[]= }
    end

    context "with invalid source data" do
      let(:store_without_backing_store) { described_class.new nil }

      it "will raise an InvalidBackingStore" do
        expect { store_without_backing_store }.to \
          raise_exception(described_class::InvalidBackingStore)
      end
    end
  end

  describe "#[]" do
    context "with first_name" do
      subject { instance["first_name"] }

      it { is_expected.to eql "Joe" }
    end

    context "with age" do
      subject { instance["age"] }

      it { is_expected.to be 20 }
    end
  end

  describe "#[]=" do
    let(:store) { subject }

    it "will update stored value" do
      expect { store["first_name"] = "Jane" }.to \
        change { store["first_name"] }.from("Joe").to("Jane")
    end
  end

  describe "#fetch" do
    context "with multiple keys" do
      subject { instance.fetch :first_name, :region }

      it "will return hash of requested keys" do
        is_expected.to eql({ "first_name" => "Joe", "region" => "Manchester" })
      end
    end

    context "with array of keys" do
      subject { instance.fetch %w[first_name region] }

      it "will return hash of requested keys" do
        is_expected.to eql({ "first_name" => "Joe", "region" => "Manchester" })
      end
    end
  end

  describe "#purge!" do
    subject { instance.keys }

    before { instance.purge! }

    it "will remove all keys" do
      is_expected.to have_attributes empty?: true
    end
  end
end
