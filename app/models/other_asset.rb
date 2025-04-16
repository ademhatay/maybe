class OtherAsset < ApplicationRecord
  include Accountable

  class << self
    def color
      "#12B76A"
    end

    def icon
      "plus"
    end

    def display_name
      "Diğer varlık"
    end

    def classification
      "asset"
    end
  end
end
