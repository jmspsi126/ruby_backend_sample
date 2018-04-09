class FindSendFileFlags
  attr_accessor :logfile_requests, :send_file_flags

  def initialize(logfile_requests, send_file_flags)
    @logfile_requests = logfile_requests
    @send_file_flags = send_file_flags
  end

  def flags_for(loco, system)
    send_file_flags.each do |flag|
      flag.pending = pending_request?(loco, system, flag)
    end
    send_file_flags
  end

  def flag_for(loco, system, flag)
    flag.pending = pending_request?(loco, system, flag)
    flag
  end

  def pending_request?(loco, system, flag)
    logfile_requests.exists?({
      liis_locomotive_id: loco.id,
      liis_system_id: system.id,
      send_file_flag_enum_value: flag.enum_value,
      status: :pending
    })
  end
end

