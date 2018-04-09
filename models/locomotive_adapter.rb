class LocomotiveAdapter
  attr_accessor :title, :locomotive_type, :id_assigned, :commission_date,
    :description, :locomotive_status, :total_faults, :time_utc_last_alarm,
    :time_utc, :time_offset, :latitude, :longitude, :rotation, :waypoint,
    :time_utc_gps, :address, :id, :account_id

  def initialize(loco, liis_loco)
    @id = loco.id
    @account_id = liis_loco.customer_id
    @title = loco.title
    @locomotive_type = loco.locomotive_type
    @id_assigned = loco.id_assigned
    @commission_date = loco.commission_date
    @description = loco.description
    @gps = liis_loco.gps
    @latitude = liis_loco.latitude
    @longitude = liis_loco.longitude
    @status_locomotive = liis_loco.status_locomotive
    @time_utc = liis_loco.time_utc
    @time_offset = liis_loco.time_offset
    @total_faults = liis_loco.total_faults
    @rotation = liis_loco.rotation
    @time_utc_last_alarm = liis_loco.time_utc_last_alarm
    @waypoint = liis_loco.waypoint
    @time_utc_gps = liis_loco.time_utc_gps
    @address = liis_loco.address
    @status_gps = liis_loco.status_gps
    @out_of_service = loco.out_of_service
  end

  def self.adapt_all(locos, liis_locos)
    locos.map do |loco|
      corresponding_liis_loco = liis_locos.find do |liis_loco|
        liis_loco.locomotive_id.to_s == loco.id_assigned.to_s
      end

      if corresponding_liis_loco
        self.new(loco, corresponding_liis_loco)
      end
    end.compact
  end

  private
  attr_accessor :loco, :liis_loco
end

