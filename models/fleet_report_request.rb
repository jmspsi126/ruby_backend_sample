class FleetReportRequest
  include ActiveModel::Validations

  attr_accessor :to, :from

  validates_presence_of :to, :from
  validate :valid_dates

  def initialize(attrs)
    self.to = attrs.delete(:to)
    self.from = attrs.delete(:from)
    @success = false
  end

  def response_body
    { success: @success,
      errors: self.errors }
  end

  def valid_dates
    [:to, :from].each do |date_attr_name|
      date = self.send(date_attr_name)

      if date.present? && !valid_date?(date)
        self.errors[date_attr_name] << "Is invalid. Format is 'YYYY-MM-DD'"
      end
    end
  end

  def valid_date?(date)
    Date.strptime(date, "%Y-%m-%d")
  rescue ArgumentError
    false
  end

  def send_request(tenant)
    @report = LIIS::FleetReport.get(tenant.id, to_params)
  end

  def to_params
    { to: self.to, from: self.from }
  end

  def success?
    @report && @report.success
  end

  def error_message
    @report && @report.error_message
  end

  def file_path
    @report && File.join(Rails.root, @report.file)
  end

  def file_basename
    @report && File.basename(file_path)
  end
end
