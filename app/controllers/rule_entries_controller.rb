class RuleEntriesController < ApplicationController

  before_filter :authenticate_user!, only: [:create]
  before_filter :only => [:create] do 
    redirect_to :new_user_session unless current_user && current_user.admin?
  end
  
  # GET /rule_entries
  # GET /rule_entries.json
  def index
    @title = t('actions.listing') + " " + t('activerecord.models.rule_entries')
    @rule = Rule.find(params[:rule_id])    
    @rule_entries = @rule.rule_entries.order('order_id')
    @search_form_path = rule_rule_entries_path(@rule)
    @licenses = License.search(params[:license_name], params[:page], 6)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rule_entries }
    end
  end

  # POST /rule_entries
  # POST /rule_entries.json
  def create
    @title = t('actions.listing') + " " + t('activerecord.models.rule_entries')    
    @rule = Rule.find(params[:rule_id])    
    
    @rule_entries = @rule.rule_entries.order('order_id')
    @search_form_path = rule_rule_entries_path(@rule)
    @licenses = License.search(params[:license_name], params[:page], 6)

    if !params[:del].nil?
      license_del = params[:del]
      @rule_entry = RuleEntry.find(license_del)
      @rule_entry.destroy
      new_order_id = 0
      @rule.rule_entries.order('order_id').each do |rule_entry|
        new_order_id = new_order_id + 1
        rule_entry.order_id = new_order_id
        rule_entry.save
      end
    end

    if !params[:add].nil?
      rule_id = params[:rule_id]
      license_id = params[:add]
      @rule_entry = RuleEntry.new
      @rule_entry.rule_id = rule_id
      @rule_entry.license_id = license_id
      @rule_entry.order_id = @rule.rule_entries.count + 1
      @rule_entry.save
    end

    respond_to do |format|
      format.html { render action: "index" }
      format.json { render json: @rule_entry }
    end
  end

end
