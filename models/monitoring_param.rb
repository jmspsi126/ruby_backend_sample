class MonitoringParam < ActiveRecord::Base
  acts_as_tenant :account

  scope(:for_display, ->{ where(display_monitoring: true).order(:order_monitoring) })
  scope(:health, ->{ where(param_type: "Health") })
  scope(:status, ->{ where(param_type: "status") })

  attr_accessible :chart_max, :chart_min, :fmi, :group, :source, :spn, :category,
                  :threshold_max, :threshold_min, :title, :description,
                  :units, :cummings_pgn, :qes_variable, :param_type,
                  :display_loco_detail, :display_monitoring,
                  :display_maintenance_monitoring,
                  :order_loco_detail, :order_monitoring, :order_maintenance_monitoring,
                  :mode_power,:mode_brake,:mode_fuel,:mode_gps,:mode_loading,:mode_subsystem,
                  :mode_wide,:percent_change, :fault_ids, :locomotive_type_id

  belongs_to :account
  belongs_to :locomotive_type

  has_and_belongs_to_many(:faults)
  accepts_nested_attributes_for(:faults)
  
  PARAM_CATEGORIES = ["Pressure", "Temperature", "Electrical", "Locomotive", "Blended Brake", "Trainlines"]
  PARAM_TYPES = ["Health", "Status"]

  def self.for_account(account)
    account_id = account ? account.id : nil
    self.where(account_id: account_id)
  end
  
  def self.for_locotype(locomotive_type)
    self.where(locomotive_type_id:locomotive_type)
  end

  def self.categories
    PARAM_CATEGORIES
  end

  def self.types
    PARAM_TYPES
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |param|
        csv << param.attributes.values_at(*column_names)
      end
    end
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      param = find_by_id(row["id"]) || new
      param.attributes = row.to_hash.slice(*accessible_attributes)
      param.save!
    end
  end

  def self.filtered_params(params)
    params.select {|k,v| k.match(/^ai|^di|^mi|^do|^zz/) unless k.nil?}
  end

  def self.import_from_master(param_data, ta_mode_map_csv, category_map_csv)
    @order_loco_detail_filtered = filtered_params all.each_with_object({}) {|p,hsh| hsh[p.qes_variable]=p.order_loco_detail }
    @order_monitoring_filtered = filtered_params all.each_with_object({}) {|p,hsh| hsh[p.qes_variable]=p.order_monitoring }
    destroy_all

    ta_mode_map = {}
    CSV.foreach(ta_mode_map_csv.path, headers: true, :encoding => 'ISO-8859-1') do |row|
    ta_mode_map[row["Health Parm name"]] = {
      :mode_power => row["Power"] == "x",
      :mode_brake => row["Brake"] == "x",
      :mode_fuel => row["Fuel"] == "x",
      :mode_gps => row["GPS"] == "x",
      :mode_loading => row["loading"] == "x",
      :mode_subsystem => row["subsystem"] == "x",
      :mode_wide => row["wide"] == "x"
    }
    end

    categories = {}
    CSV.foreach(category_map_csv.path, headers: false) { |row| categories[row[0]] = row[1] }

    CSV.foreach(param_data.path, headers: true) do |row|
      next if ["Power parms", "blended brake parms", "eng stats", "Status Monitoring"].include?(row["S CODE"])
      break if row["S CODE"] == "Revision History"
      qesVars = row["QES Variable/ BOS id"].split(',')
      next if qesVars.first == "deleted"
      systemVar = (qesVars.count == 1)

      ["sytem parameter", "Eng 1 parameter", "Eng 2 parameter"].each do |paramCol|
        paramName = row[paramCol]
        next if paramName.nil?
        qesVar    = qesVars[0]
        qesVar    = qesVars[1] if ["Eng 2 parameter"].include?(paramCol) and qesVars.count > 1
        paramDspl = row["WEB display page, LD=Loco Detail, HM=Health Monitoring, SM=Status Monitoring, MM=Maint Monitoring"]
        if paramDspl.nil? then paramDspl = [] else paramDspl = paramDspl.split(", ") end
        Rails.logger.info("#{paramDspl}")
        # Find the param in the TA mode map
        ta_modes  = ta_mode_map[paramName]

        # Line up cols
        paramAttributes = {
          :fmi => row["F CODE"],
          :group => row["Grouping"],
          :source => row["CDS Source Data"],
          :spn => row["S CODE"],
          :category => categories[paramName],
          :title => paramName,
          :description => row["NOTES"],
          :units => row["Received Units"],
          :cummings_pgn => row["Cummins PGN"],
          :qes_variable => qesVar.strip,
          :param_type => if paramDspl.include?("HM") then "Health" elsif paramDspl.include?("SM") then "Status" else "" end,
          :display_loco_detail => paramDspl.include?("LD"),
          :display_monitoring => (paramDspl.include?("HM") || paramDspl.include?("SM")),
          :display_maintenance_monitoring => paramDspl.include?("MM"),
          :percent_change => row["Data Send Frequency"],
          :order_loco_detail => @order_loco_detail_filtered[qesVar.strip],
          :order_monitoring => @order_monitoring_filtered[qesVar.strip]
        }

        # Create the param
        create!(paramAttributes.merge(ta_mode_map[paramName] || {}))
      end
    end

    LIIS::Locomotive.new.updates_model('monitoring_params')
  end

  def self.param_sort_order(account_id, column='created_at')
    params = all.each_with_object({}) {|p,hsh| hsh[p.qes_variable]=p.order_loco_detail }.select {|k,v| k.match(/^ai|^di|^mi|^do|^zz/) unless k.nil?}
    params.select {|k,v| k.match(/^ai|^di|^mi|^do|^zz/) unless k.nil?}
  end


def self.param_sort_test
  all.count
end
end
