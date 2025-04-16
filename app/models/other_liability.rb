class OtherLiability < ApplicationRecord
  include Accountable

  class << self
    def color
      "#737373"
    end

    def icon
      "minus"
    end

    def display_name
      "Diğer Borç"
    end

    def classification
      "liability"
    end
  end
end
