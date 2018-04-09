module Api
  class AlarmsController < ApplicationController
    include ApipieDescriptions::Alarms

    before_filter :authenticate_and_scope!

    apipie_alarms_show
    def show
      liis_alarm = LIIS::Alarm.find(params[:id], current_tenant)

      local_alarm = Fault.where(code_display: liis_alarm.alarm_id).first
      _alarm = FaultAdapter.new(liis_alarm, local_alarm)
      _alarm.fault = local_alarm

      render json: _alarm
    end
  end
end
