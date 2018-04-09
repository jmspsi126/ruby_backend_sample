class FleetReport < ActiveRecord::Base
  attr_accessible :file_path, :id

  def file_basename
    file_path && File.basename(file_path)
  end
end
