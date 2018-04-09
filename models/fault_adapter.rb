class FaultAdapter
  attr_accessor :title, :cms_id, :gps, :id, :alarm_id,
  :liis_code, :code_display, :fault

  def initialize(remote, local, loco=nil)
    local_locomotive = loco || locomotive_find_by_id_assigned(remote.locomotive_id)
    @cms_id = local.id
    @alarm_id = local.code_display
    @gps = remote.gps
    @title = local.title
    @alarm_status = remote.alarm_status
    @locomotive_id = local_locomotive.id
    @severity = remote.severity
    @system_id = local.system_id
    @time_utc_on = remote.time_utc_on
    @time_utc_off = remote.time_utc_off
    @system_name = local.system_name
    @liis_id = remote._id
  end

  def locomotive_find_by_id_assigned(id_assigned)
    local_locomotive = Locomotive.where("id_assigned" => id_assigned).first
  end

  def self.adapt_all(faults, liis_faults, loco = nil)
    liis_faults.map do |liis_fault|
      corresponding_local_fault = faults.find do |fault|
        liis_fault.alarm_id.to_s == fault.code_display.to_s
      end

      if corresponding_local_fault
        self.new(liis_fault, corresponding_local_fault, loco)
      end
    end.compact
  end
end
