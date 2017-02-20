require "spec_helper"

describe DocumentSerializable do
  class TestClass
    def self.before_validation
    end

    include DocumentSerializable

    property :slug
    property :id, Integer

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

      property :name

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
      property :name
    end

    test = Subclass.new slug: "test-slug", id: "5", name: "Testname"
    expect(test.send(:property_object).attributes).to eq id: 5, slug: "test-slug", name: "Testname"
  end
end