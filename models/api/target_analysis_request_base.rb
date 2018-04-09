class Api::TargetAnalysisRequestBase
  include ActiveModel::Validations

  VALID_MODES = %w(power loading fuel brake wide subsystem)

  ERROR_MESSAGES = {
    at_required: "Please provide a timestamp",
    at_invalid: "The timestamp provided is not valid. format: YYYY-MM-DDTHH:MM:SS+00:00",
    mode_required: "Please provide an analysis mode",
    mode_invalid: "Invalid mode. Valid options are #{VALID_MODES.join(",")}",
    from_required: "Please provide a :from parameter",
    to_required: "Please provide a :to parameter",
    from_invalid: "The :from param is invalid. Format: YYYY-MM-DDTHH:MM:SS+00:00",
    to_invalid: "The :to param is invalid. Format: YYYY-MM-DDTHH:MM:SS+00:00"
  }

  def self.epoch(*attr_names)
    attr_names.each do |attr_name|
      define_method("#{attr_name}_epoch") do
        epoch(self.send(attr_name))
      end
    end
  end

  def parse_date(date)
    DateTime.strptime(date, "%Y-%m-%dT%H:%M:%S%:z")
  rescue TypeError, ArgumentError
    nil
  end

  def error_messages
    errors.values.flatten
  end

  def epoch(date_string)
    parse_date(date_string).to_i
  end

  def validate_date(attr)
    val = self.send(attr)

    if val.present? && parse_date(val).nil?
      self.errors[attr] << ERROR_MESSAGES["#{attr}_invalid".to_sym]
    end
  end
end
