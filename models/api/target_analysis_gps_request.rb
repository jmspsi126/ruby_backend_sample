class Api::TargetAnalysisGpsRequest < Api::TargetAnalysisRequestBase
  attr_accessor :from, :to
  epoch :from, :to

  validates_presence_of :to, message: ERROR_MESSAGES[:to_required]
  validates_presence_of :from, message: ERROR_MESSAGES[:from_required]

  validate :valid_dates

  def initialize(attrs={})
    @from = attrs[:from]
    @to = attrs[:to]
  end

  def valid_dates
    validate_date(:to)
    validate_date(:from)
  end

  def send_request(loco_id, account_id)
    LIIS::TargetAnalysisGps.fetch(
      loco_id,
      account_id,
      from: from_epoch,
      to: to_epoch
    )
  end
end
