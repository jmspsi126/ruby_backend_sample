class Fault < ActiveRecord::Base
  acts_as_tenant :account

  scope(:for_display, ->{ where(hidden: false) })

  attr_accessible :fmi, :spn, :title, :system_id, :severity, :explanation,
                  :locomotive_effect, :operator_action, :maintainer_action,
                  :account_id, :hidden, :needs_notification, :qes_variable,
                  :cummins_variable, :data_dictionary, :code_display, 
                  :monitoring_param_ids, :locomotive_type_id

  def to_notification_settings
    { code_display: self.code_display,
      needs_notification: self.needs_notification?  }
  end

  SEVERITY_LEVELS = [0, 1, 2, 3]

  belongs_to :system
  belongs_to :account
  belongs_to :locomotive_type

  has_many :resolution_notes

  has_and_belongs_to_many(
    :monitoring_params,
    class_name: "MonitoringParam"
  )

  accepts_nested_attributes_for(:monitoring_params)

  after_initialize :init

  def self.for_account(account)
    account_id = account ? account.id : nil
    self.where(account_id: account_id)
  end
  
  def self.for_locotype(locomotive_type)
    self.where(locomotive_type_id:locomotive_type)
  end
  
  def init
    self.hidden = false if self.hidden.nil?
    self.needs_notification = false if self.needs_notification.nil?
  end

  def corresponds_to_remote?(other)
    other.fmi_id.to_s == fmi.to_s &&
      other.spn_id.to_s == spn.to_s &&
      system_matches?(other.system_id) &&
      other.customer_id.to_s == account.try(:id).to_s
  end

  def subscribe_button_text
    needs_notification? ? "Unsubscribe" : "Subscribe"
  end

  def hidden_button_text
    hidden? ? "Visible" : "Hidden"
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |fault|
        csv << fault.attributes.values_at(*column_names)
      end
    end
  end

  def self.import(file)
    CSV.table(file.path, :encoding => 'windows-1251') do |row|
      fault = find_by_id(row["id"]) || new
      fault.attributes = row.to_hash.slice(*accessible_attributes)
      fault.save!
    end
  end

  def self.import_from_master(file)
    destroy_all

    system_ids = {}
    System.all.each { |system| system_ids[system.name] = system.id }

    CSV.foreach(file.path, headers: true, :encoding => 'windows-1251:utf-8') do |row|
      attributes = {
        :fmi => row["fmi"],
        :spn => row["spn"],
        :title => row["FAULT TITLE / KB TITLE (Root)"],
        :system_id => system_ids[row["SYSTEM"]],
        :severity => row["Fault Level"],
        :explanation => row["Fault Description"],
        :locomotive_effect => row["Locomotive Effect"],
        :operator_action => row["OPERATOR Action / Alarm Resolution"],
        :maintainer_action => row["MAINTAINER Action / Alarm Resolution"],
        :hidden => row["Hidden"],
        :needs_notification => row["Needs Notification"],
        :qes_variable => row["QES fault #"],
        :cummins_variable => row["Cummins fault #"],
        :data_dictionary => row["CDS fault number as defined by DataDictionary.  See DataDictionary as ruling document in case of discrepancies (hex)"],
        :code_display => row["alarm code for web display"],
      }

      Fault.create! attributes
    end

   LIIS::Locomotive.new.updates_model('faults')
  end

  def self.associate_params(file)
    prmsxqvar = {}
    MonitoringParam.all.each { |param| prmsxqvar[param.qes_variable] = param }

    CSV.foreach(file.path, headers: true) do |row|
      fault = find_by_title(row["title"])
      headers = row.headers.compact
      headers.each do |qvar|
        associate = (row[qvar] && row[qvar].downcase == "x")
        unless fault.nil?
          fault.monitoring_params<<prmsxqvar[qvar] if prmsxqvar[qvar] && associate
        end
      end
    end
  end

  def system_name
    system.name rescue ""
  end

  def visibility_sync(fault)
    jdata = {}
    jdata[:fault_id], jdata[:hidden]  = fault.code_display, fault.hidden
    call(fault).fault_upsert(fault.code_display,jdata.to_json)
  end

  def notification_sync(fault)
    jdata = {}
    jdata[:fault_id], jdata[:needs_notification] = fault.code_display, fault.needs_notification
    call(fault).fault_upsert(fault.code_display,jdata.to_json)
  end

  def call(fault)
    liis(fault)
  end

  def liis(fault)
    LIIS::Locomotive.new(account_id: fault.account_id, locomotive_id: 1)
  end

  private
  def system_matches?(remote_system_id)
    remote_system_id = remote_system_id.to_s
    system_id_assigned = system.try(:id_assigned).to_s

    remote_system_id == system_id_assigned
  end
end