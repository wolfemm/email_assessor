$:.unshift File.expand_path("../lib",__FILE__)
require "email_assessor"

class TestModel
  include ActiveModel::Validations

  def initialize(attributes = {})
    @attributes = attributes
  end

  def read_attribute_for_validation(key)
    @attributes[key]
  end
end
