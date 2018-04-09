class Api::AlarmHealthSnapshotsController < ApplicationController
  include ApipieDescriptions::AlarmHealthSnapshots

  before_filter :authenticate_and_scope!
  before_filter :deny_access_if_not_enabled
  before_filter :require_at_param
  before_filter :require_fault_id_param
  before_filter :load_locos


  apipie_alarm_health_snapshots_show
  def show
    fault = Fault.find(params[:fault_id])

    snapshot = LIIS::AlarmHealthSnapshot.for(
      loco_id: @loco.id_assigned,
      at_time: at.to_i,
      account_id: current_tenant.id
    )
    ap snapshot.health_params.count
    monitoring_params = fault.monitoring_params.map(&:qes_variable)
    snapshot_params = snapshot.health_params.map {|hp| hp['qes_variable']}
    ap monitoring_params
    ap snapshot_params
    # snapshot.health_params.select {|hp| monitoring_params.include?(hp['qes_varable'])}
    # binding.pry

    # @snapshot = snapshot.health_params.select {|hp| hp['qes_variable'].in? monitoring_params }.as_json
    snapshot.merge_with(fault.monitoring_params)

    @snapshot = snapshot.as_json
  end

  private

  def deny_access_if_not_enabled
    deny_access unless current_tenant.has_feature_enabled?(
      :alarm_health_snapshot
    )
  end

  def require_at_param
    unless at.present?
      render(
        json: { error: "Please specify a date" },
        status: :bad_request
      )
    end
  end

  def require_fault_id_param
    unless fault_id.present?
      render(
        json: { error: "Please provide a fault id" },
        status: :bad_request
      )
    end
  end

  def at
    @at ||= DateTime.strptime(params[:at], "%Y-%m-%dT%H:%M:%S%:z")
  rescue TypeError, ArgumentError
    @at = nil
  end

  def fault_id
    params[:fault_id]
  end

  def load_locos
    @loco = Locomotive.find(params[:locomotive_id])
  end

end
