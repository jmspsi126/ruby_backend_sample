class MonitoringParamAdapter
  # liis
  attr_accessor :time_utc, :value, :qes_variable, :locomotive_name

  # local
  attr_accessor :account_id, :spn, :fmi, :cummings_pgn, :qes_variable,
    :trainline, :group, :units, :source, :title, :description, :param_type,
    :category, :display_loco_detail, :display_monitoring,
    :display_maintenance_monitoring, :order_loco_detail, :order_monitoring,
    :order_maintenance_monitoring, :threshold_min, :threshold_max, :chart_min,
    :chart_max, :qes_sequence, :active_alarms

  def initialize(param, liis_param)
    @time_utc = liis_param.time_utc
    @value = liis_param.value
    @locomotive_name = liis_param.locomotive_name

    @account_id = param.account_id
    @spn = param.spn
    @fmi = param.fmi
    @cummings_pgn = param.cummings_pgn
    @qes_variable = param.qes_variable
    @trainline = param.trainline
    @group = param.group
    @units = param.units
    @source = param.source
    @title = param.title
    @description = param.description
    @category = param.category
    @order_loco_detail = param.order_loco_detail
    @display_loco_detail = param.display_loco_detail
    @qes_sequence = liis_param.qes_sequence
    @active_alarms = liis_param.active_alarms
  end

  def self.adapt_all(params, liis_params)
    liis_params.map do |liis_param|

      corresponding_local_param = params.find do |param|
        liis_param.qes_variable.to_s == param.qes_variable.to_s
      end

      if(corresponding_local_param)
        self.new(corresponding_local_param, liis_param)
      end

    end
      .select { |p| !p.nil? }
      .sort_by { |p| p.order_loco_detail }
      .select { |p| p.display_loco_detail }
  end
end
