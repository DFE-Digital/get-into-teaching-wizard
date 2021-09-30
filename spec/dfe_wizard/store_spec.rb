require "rails_helper"

describe DFEWizard::Store do
  subject { instance }

  let(:new_data) { { "first_name" => "Joe", "last_name" => nil, "age" => 20 } }
  let(:preexisting_data) { { "first_name" => "James", "last_name" => "Doe", "region" => "Manchester" } }
  let(:instance) { described_class.new new_data, preexisting_data }

  describe ".new" do
    context "with valid source data" do
      it { is_expected.to be_instance_of(described_class) }
      it { is_expected.to respond_to :[] }
      it { is_expected.to respond_to :[]= }
    end

    context "with invalid new_data source" do
      subject { described_class.new nil, preexisting_data }

      it "raises an InvalidBackingStore" do
        expect { subject }.to raise_exception(DFEWizard::Store::InvalidBackingStore)
      end
    end

    context "with invalid preexisting_data source" do
      subject { described_class.new preexisting_data, nil }

      it "raises an InvalidBackingStore" do
        expect { subject }.to raise_exception(DFEWizard::Store::InvalidBackingStore)
      end
    end
  end

  describe "#[]" do
    context "when the attribute exists in new and preexisting data" do
      subject { instance["first_name"] }

      it { is_expected.to eq("Joe") }
    end

    context "when the attribute is nil in the new data and not nil in the preexisting data" do
      subject { instance["last_name"] }

      it { is_expected.to be_nil }
    end

    context "when the attribute exists in only the new data" do
      subject { instance["age"] }

      it { is_expected.to eq(20) }
    end

    context "when the attribute exists in only the preexisting data" do
      subject { instance["region"] }

      it { is_expected.to eq("Manchester") }
    end
  end

  describe "#[]=" do
    it "will update stored value" do
      expect { subject["first_name"] = "Jane" }.to \
        change { subject["first_name"] }.from("Joe").to("Jane")
    end
  end

  describe "#preexisting" do
    it { expect(instance.preexisting(:first_name)).to eq("James") }
    it { expect(instance.preexisting(:age)).to be_nil }
  end

  describe "#fetch" do
    context "with multiple keys" do
      subject { instance.fetch :first_name, :last_name, :age, :region, source: source }

      context "when source is both" do
        let(:source) { :both }

        it { is_expected.to eql({ "first_name" => "Joe", "last_name" => nil, "age" => 20, "region" => "Manchester" }) }
      end

      context "when source is new" do
        let(:source) { :new }

        it { is_expected.to eql({ "first_name" => "Joe", "last_name" => nil, "age" => 20, "region" => nil }) }
      end

      context "when source is preexisting" do
        let(:source) { :preexisting }

        it { is_expected.to eql({ "first_name" => "James", "age" => nil, "last_name" => "Doe", "region" => "Manchester" }) }
      end
    end

    context "with array of keys" do
      subject { instance.fetch %w[first_name age region] }

      it { is_expected.to eql({ "first_name" => "Joe", "age" => 20, "region" => "Manchester" }) }
    end

    context "when a key is not present in the store" do
      subject { instance.fetch %w[first_name missing_key] }

      it "will return it with a nil value in the hash" do
        is_expected.to eql({ "first_name" => "Joe", "missing_key" => nil })
      end
    end
  end

  describe "#persist" do
    subject! { instance.persist({ first_name: "Jim" }) }

    it { is_expected.to be_truthy }
    it { expect(instance["first_name"]).to eq("Jim") }
    it { expect(instance["age"]).to eq(20) }
  end

  describe "#persist_preexisting" do
    subject! { instance.persist_preexisting({ first_name: "Jim" }) }

    it { is_expected.to be_truthy }
    it { expect(instance.preexisting("first_name")).to eq("Jim") }
    it { expect(instance.preexisting("age")).to be_nil }
  end

  describe "#purge!" do
    before { instance.purge! }

    subject { instance.keys }

    it "will remove all keys" do
      is_expected.to have_attributes empty?: true
    end
  end

  describe "#prune!" do
    subject { instance.keys }

    let(:leave) { "age" }

    before { instance.prune!(leave: leave) }

    it "will remove all keys that aren't marked as 'leave'" do
      expect(instance.keys).not_to include(new_data.keys.excluding(leave))
    end

    it "will keep all keys that are marked as 'leave'" do
      expect(instance.keys).to include(leave)
    end
  end
end
