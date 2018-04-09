class Api::TargetAnalysisRequest < Api::TargetAnalysisRequestBase
  attr_accessor :at, :mode
  epoch :at

  validates_presence_of :at, message: ERROR_MESSAGES[:at_required]
  validates_presence_of :mode, message: ERROR_MESSAGES[:mode_required]

  validate :valid_date

  validates_inclusion_of(
    :mode,
    in: VALID_MODES,
    message: ERROR_MESSAGES[:mode_invalid],
    allow_blank: true
  )

  def initialize(attrs={})
    @mode = attrs[:mode]
    @at = attrs[:at]
  end

  def valid_date
    validate_date(:at)
  end

  def send_request(locomotive_id, account_id)
    req = LIIS::TargetAnalysis.fetch(
      locomotive_id: locomotive_id,
      mode: mode,
      at: at_epoch,
      account_id: account_id
    )

    req.merge_with(MonitoringParam)
    req.as_json
  end

end
