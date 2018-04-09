class HealthParams < ActiveRecord::Base
  acts_as_tenant :account

  attr_accessible :chart_max, :chart_min, :fmi, :group, :source, :spn,
                  :threshold_max, :threshold_min, :threshold_units, :title,
                  :units, :account_id, :description, :cummings_pgn, :qes_variable,
                  :display_toggle_loco_detail, :display_toggle_monitoring,
                  :display_toggle_maint_monitoring, :category

  belongs_to :account

  HEALTH_CATEGORIES = ["Power", "Blended Brake", "Eng Stats", "Status"]

  def self.categories
    HEALTH_CATEGORIES
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

end
