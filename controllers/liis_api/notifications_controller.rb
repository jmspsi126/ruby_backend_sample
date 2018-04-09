module LiisApi
  class NotificationsController < LiisController
    include ApipieDescriptions::Notifications
    respond_to :json

    apipie_notifications_create
    def create
      @alarm = LIIS::Alarm.new(params[:fault])
      @account = Account.find(@alarm.customer_id)

      ActsAsTenant.with_tenant(@account) do
        @fault = Fault.find_by_code_display(@alarm.code_display)
        @locomotive = Locomotive.find_by_id_assigned(@alarm.locomotive_id)

        unless @locomotive.out_of_service?
          notify_users_of_alarm
        end

        respond_with({}, location: nil)
      end
    end

    private
    def notify_users_of_alarm
      @account.users.each do |user|
        if(user.wants_email_notification?)
          FaultNotificationMailer.notify(user, @fault, @alarm, @locomotive, @account).deliver
        end
      end
    end
  end
end

