class LocomotiveType < ActiveRecord::Base
  attr_accessible :description, :name, :param_speed, :param_horsepower, :param_mg_power_out, 
  :param_fuel_level, :param_fuel_consumption, :param_rpm, :param_hep_power, :param_aux_power, 
  :engine_kwhrs_label, :param_engine_kwhrs, :param_engine_hours, :param_odom, :fuel_tank_size,
  :rea_map, :rea_struct, :engine_count, :param_ambient_air, :param_status_aess, :param_throttle_position,
  :param_blendedbrake, :param_trainlinelt, :param_trainlinert

  has_many :locomotives
  has_many :systems
  has_many :faults
  has_many :monitoring_params

  TYPES = ['MP33C','MP40PHTC-T4','Bench Test']

  def self.types
    TYPES
  end
end
