# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module Leaf
  module Representer
    # Represents a CreditShare value
    class QueryCreateResult < Roar::Decorator
      include Roar::JSON

      property :id
    end
  end
end
