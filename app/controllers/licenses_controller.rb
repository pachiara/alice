class LicensesController < ApplicationController

  def order_search
    case params[:order]
    when "name"
      if session[:down_name].nil?
        session[:down_name] = true
      end
      @down_name = session[:down_name]
      if session[:licenses_page] == params[:page] then
        @down_name = !session[:down_name]
        session[:down_name] = @down_name      
      end 
      if @down_name 
        @order = "name DESC, version DESC"
      else
        @order = "name ASC, version ASC"
      end
      @class_name = "btn btn-mini btn-info" 
    when "description"
      if session[:down_description].nil?
        session[:down_description] = true
      end
      @down_description = session[:down_description]
      if session[:licenses_page] == params[:page] then
        @down_description = !session[:down_description]
        session[:down_description] = @down_description
      end      
      if @down_description
        @order = "description DESC"        
      else
        @order = "description ASC"
      end
      @class_description = "btn btn-mini btn-info"
    when "license_type"
      if session[:down_license_type].nil?
        session[:down_license_type] = true
      end
      @down_license_type = session[:down_license_type]
      if session[:licenses_page] == params[:page] then
        @down_license_type = !session[:down_license_type]
        session[:down_license_type] = @down_license_type
      end
      if @down_license_type
        @order = "license_type_id DESC"
      else  
        @order = "license_type_id ASC"
      end
      @class_license_type = "btn btn-mini btn-info"
    when "category"
      if session[:down_category].nil?
        session[:down_category] = true
      end
      @down_category = session[:down_category]
      if session[:licenses_page] == params[:page] then
        @down_category = !session[:down_category]
        session[:down_category] = @down_category
      end         
      if @down_category
        @order = "category_id DESC"
      else
        @order = "category_id ASC"
      end  
      @class_category = "btn btn-mini btn-info"
    end
    return @order  
  end

  def restore_search
    if params[:page].nil? && !session[:licenses_page].nil? then
       params[:page] = session[:licenses_page]
    end
    if params[:license_name].nil? && !session[:licenses_search_name].nil? then
       params[:license_name] = session[:licenses_search_name]
    end
    if !params[:license_name].nil? && !params[:license_name].chop.empty? then
       params[:page] = 1
    end
  end

  # GET /licenses
  # GET /licenses.json
  def index
    restore_search if params[:commit] != "clear"
    @title = t('actions.listing') + " " + t('activerecord.models.licenses')
    @search_form_path = licenses_path
    @class_name = "btn btn-mini"
    @class_description = "btn btn-mini"
    @class_category = "btn btn-mini"
    @class_license_type = "btn btn-mini"
        
    if params[:order].nil? || params[:order].empty? then
      @licenses = License.search(params[:license_name], params[:page])
    else
      @licenses = License.search_order(order_search, params[:page])
    end

    session[:licenses_page] = params[:page]
    session[:licenses_search_name] = params[:license_name]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @licenses }
    end
  end

  # GET /licenses/1
  # GET /licenses/1.json
  def show
    @title = t('actions.show') + " " + t('activerecord.models.license')
    @license = License.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @license }
    end
  end

  # GET /licenses/1.text
  def download
    @license = License.find(params[:license_id])

    if @license.text_license.size > 0
    send_data @license.text_license,
              :filename => @license.name+".txt",
              :type => "application/text"
    else
      respond_to do |format|
        format.html { render action: "show" }
        format.json { render json: @license }
      end
    end
    
  end

  # GET /licenses/new
  # GET /licenses/new.json
  def new
    @title = t('actions.new') + " " + t('activerecord.models.license')
    @license = License.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @license }
    end
  end

  # GET /licenses/1/edit
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.license')
    @license = License.find(params[:id])
  end

  # POST /licenses
  # POST /licenses.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.license')
    @license = License.new(params[:license])

    respond_to do |format|
      if @license.save
        format.html { redirect_to @license, notice: t('flash.license.create.notice') }
        format.json { render json: @license, status: :created, location: @license }
      else
        format.html { render action: "new" }
        format.json { render json: @license.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /licenses/1
  # PUT /licenses/1.json
  def update
    @title = t('actions.edit') + " " + t('activerecord.models.license')
    @license = License.find(params[:id])

    respond_to do |format|
      if @license.update_attributes(params[:license])
        format.html { redirect_to licenses_url, notice:  t('flash.license.update.notice') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @license.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /licenses/1
  # DELETE /licenses/1.json
  def destroy
    @license = License.find(params[:id])
    @license.destroy

    respond_to do |format|
      format.html { redirect_to licenses_url }
      format.json { head :no_content }
    end
  end
end