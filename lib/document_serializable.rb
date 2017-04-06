require "document_serializable/version"
require "active_support"
require "active_support/core_ext"
require "hashdiff"
require "virtus"

module DocumentSerializable
  extend ActiveSupport::Concern

  included do
    def attributes
      property_object.attributes.merge(super)
    end

    def reload(options = nil)
      super
      @property_object = nil
      self
    end

    private

    def property_object
      @property_object ||= begin
        properties = self.properties
        properties = JSON.parse(properties) if properties.is_a? String
        self.class.property_class.new(properties || {})
      end
    end

    before_validation do
      self.properties = property_object.attributes
    end
  end

  class_methods do
    def property_class
      @property_class ||= begin
        Class.new(superclass.try(:property_class) || Object) { include Virtus.model(nullify_blank: true) }
      end
    end

    def attribute(name, type = String, options = {})
      property_class.send :attribute, name, type, options
      delegate name, to: :property_object
      delegate "#{name}=".to_sym, to: :property_object
    end
  end

  def previous_changes
    if defined?(super)
      super.each_with_object({}) do |(key, value), result|
        if value.last.is_a?(Hash)
          HashDiff.diff(value.first || {}, value.last).each { |diff| result[diff[1]] = diff[2..3] }
        else
          result[key] = value
        end
      end
    end
  end
end
