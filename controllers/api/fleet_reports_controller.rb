class Api::FleetReportsController < ApplicationController
  include ApipieDescriptions::FleetReports

  before_filter :authenticate_and_scope!

  apipie_fleet_reports_show
  def show
    @fleet_report_request = FleetReportRequest.new(params)

    if @fleet_report_request.valid?
      send_liis_request
    else
      render(json: {
        success: false,
        errors: @fleet_report_request.errors
      })
    end
  end
  
  apipie_fleet_reports_file
  def file
    report = FleetReport.find(params[:id])

    send_file(
      report.file_path,
      disposition: "attachment",
      filename: report.file_basename,
      type: "text/csv",
      status: 200
    )
  end

  private
  def send_liis_request
    @fleet_report_request.send_request(current_tenant)

    if @fleet_report_request.success?
      report = FleetReport.create(file_path: @fleet_report_request.file_path)

      render json: {
        success: true,
        url: file_api_fleet_report_path(report)
      }

    else

      render json: {
        success: false,
        errors: { request: [@fleet_report_request.error_message] }
      }

    end
  end
end
