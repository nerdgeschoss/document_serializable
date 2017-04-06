require "spec_helper"

describe DocumentSerializable do
  class TestClass
    def self.before_validation
    end

    include DocumentSerializable

    attribute :slug
    attribute :id, Integer

    attr_accessor :properties

    def initialize(attributes = {})
      attributes.each do |key, value|
        send "#{key}=", value
      end
    end
  end

  it "defines a class for properties" do
    test = TestClass.new slug: "test-slug", id: "5"
    expect(test.slug).to eq "test-slug"
    expect(test.id).to eq 5
  end

  it "does not interfere with other classes" do
    class AnotherTestClass
      def self.before_validation
      end

      include DocumentSerializable

      attribute :name

      attr_accessor :properties

      def initialize(attributes = {})
        attributes.each do |key, value|
          send "#{key}=", value
        end
      end
    end

    test = TestClass.new slug: "test-slug", id: "5"
    test2 = AnotherTestClass.new name: "Test Name"

    expect(test.send(:property_object).attributes).to eq id: 5, slug: "test-slug"
    expect(test2.send(:property_object).attributes).to eq name: "Test Name"
  end

  it "does inherit properties from it's parent" do
    class Subclass < TestClass
      attribute :name
    end

    test = Subclass.new slug: "test-slug", id: "5", name: "Testname"
    expect(test.send(:property_object).attributes).to eq id: 5, slug: "test-slug", name: "Testname"
  end

  describe "#previous_changes" do
    context "if the including class defines #previous_changes" do
      let(:user_class) do
        ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
        ActiveRecord::Schema.define do
          self.verbose = false

          create_table :users, :force => true do |t|
            t.string :first_name
            t.string :last_name
            t.text :properties

            t.timestamps
          end
        end

        Class.new(ActiveRecord::Base) do
          include DocumentSerializable
          self.table_name = "users" # because of anonymous class

          serialize :properties, JSON # sqlite has no json type, so we use a text coloumn and serialize on our own

          attribute :some_property, String
        end
      end

      let(:updated_user) do
        user_class.create(first_name: "Max", last_name: "Mustermann", some_property: "bar").tap do |user|
          user.update_attributes(first_name: "Sabrina", some_property: "muff")
        end
      end

      subject { updated_user.previous_changes }

      it { is_expected.to include("first_name"=>["Max", "Sabrina"], "some_property"=>["bar", "muff"]) }
    end

    context "if the including class does not define #previous_changes" do
      subject { TestClass.new.previous_changes }
      it { is_expected.to be_nil }
    end
  end
end
