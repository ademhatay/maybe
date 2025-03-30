class Period
  include ActiveModel::Validations, Comparable

  class InvalidKeyError < StandardError; end

  attr_reader :key, :start_date, :end_date

  validates :start_date, :end_date, presence: true, if: -> { PERIODS[key].nil? }
  validates :key, presence: true, if: -> { start_date.nil? || end_date.nil? }
  validate :must_be_valid_date_range

  PERIODS = {
    "last_day" => {
      date_range: [ 1.day.ago.to_date, Date.current ],
      label_short: "1G",
      label: "Son 1 Gün",
      comparison_label: "Geçmiş 1 güne göre"
    },
    "current_week" => {
      date_range: [ Date.current.beginning_of_week, Date.current ],
      label_short: "ŞimdikiHafta",
      label: "Şimdiki Hafta",
      comparison_label: "Hafta başından beri"
    },
    "last_7_days" => {
      date_range: [ 7.days.ago.to_date, Date.current ],
      label_short: "7G",
      label: "Last 7 Days",
      comparison_label: "Geçmiş 7 güne göre"
    },
    "current_month" => {
      date_range: [ Date.current.beginning_of_month, Date.current ],
      label_short: "BuAy",
      label: "Şimdiki Ay",
      comparison_label: "Ay başından beri"
    },
    "last_30_days" => {
      date_range: [ 30.days.ago.to_date, Date.current ],
      label_short: "30G",
      label: "Son 30 Gün",
      comparison_label: "Geçmiş 30 güne göre"
    },
    "last_90_days" => {
      date_range: [ 90.days.ago.to_date, Date.current ],
      label_short: "90G",
      label: "Son 90 Gün",
      comparison_label: "Geçmiş 90 güne göre"
    },
    "current_year" => {
      date_range: [ Date.current.beginning_of_year, Date.current ],
      label_short: "BuYıl",
      label: "Şimdiki Yıl",
      comparison_label: "Yıl başından beri"
    },
    "last_365_days" => {
      date_range: [ 365.days.ago.to_date, Date.current ],
      label_short: "365G",
      label: "Son 365 Gün",
      comparison_label: "Geçmiş 365 güne göre"
    },
    "last_5_years" => {
      date_range: [ 5.years.ago.to_date, Date.current ],
      label_short: "5Y",
      label: "Son 5 Yıl",
      comparison_label: "Geçmiş 5 yıla göre"
    }
  }

  class << self
    def from_key(key)
      unless PERIODS.key?(key)
        raise InvalidKeyError, "Geçersiz anahtar: #{key}. Geçerli anahtarlar: #{PERIODS.keys.join(', ')}"
      end

      start_date, end_date = PERIODS[key].fetch(:date_range)

      new(key: key, start_date: start_date, end_date: end_date)
    end

    def custom(start_date:, end_date:)
      new(start_date: start_date, end_date: end_date)
    end

    def all
      PERIODS.map { |key, period| from_key(key) }
    end
  end

  PERIODS.each do |key, period|
    define_singleton_method(key) do
      from_key(key)
    end
  end

  def initialize(start_date: nil, end_date: nil, key: nil, date_format: "%b %d, %Y")
    @key = key
    @start_date = start_date
    @end_date = end_date
    @date_format = date_format
    validate!
  end

  def <=>(other)
    [ start_date, end_date ] <=> [ other.start_date, other.end_date ]
  end

  def date_range
    start_date..end_date
  end

  def days
    (end_date - start_date).to_i + 1
  end

  def within?(other)
    start_date >= other.start_date && end_date <= other.end_date
  end

  def interval
    if days > 366
      "1 hafta"
    else
      "1 gün"
    end
  end

  def label
    if key_metadata
      key_metadata.fetch(:label)
    else
      "Özel Aralık"
    end
  end

  def label_short
    if key_metadata
      key_metadata.fetch(:label_short)
    else
      "Özel"
    end
  end

  def comparison_label
    if key_metadata
      key_metadata.fetch(:comparison_label)
    else
      "#{start_date.strftime(@date_format)} to #{end_date.strftime(@date_format)}"
    end
  end

  private
    def key_metadata
      @key_metadata ||= PERIODS[key]
    end

    def must_be_valid_date_range
      return if start_date.nil? || end_date.nil?
      unless start_date.is_a?(Date) && end_date.is_a?(Date)
        errors.add(:start_date, "geçersiz tarih, #{start_date.inspect}")
        errors.add(:end_date, "geçersiz tarih, #{end_date.inspect}")
        return
      end

      errors.add(:start_date, "başlangıç tarihi, bitiş tarihinden büyük olamaz") if start_date > end_date
    end
end
