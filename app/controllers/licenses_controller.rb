class LicensesController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update, :destroy, :new, :create]
  before_action :set_license, only: [:show, :edit, :update, :destroy]

  def restore_search
    # Premuto tasto colonna
    if !params[:sort_column].nil? && params[:page].nil? then
      if params[:sort_column] != session[:licenses_sort_column] then
        params[:sort_order] = " ASC"
      else
        if session[:licenses_sort_order] == " ASC"
          params[:sort_order] = " DESC"
        else
          params[:sort_order] =  " ASC"
        end
      end
    end

    if params[:page].nil? && params[:restart_page].nil? && !session[:licenses_page].nil? then
       params[:page] = session[:licenses_page]
    end
    if params[:license_name].nil? && !session[:licenses_search_name].nil? then
       params[:license_name] = session[:licenses_search_name]
    end
    if params[:sort_column].nil? && !session[:licenses_sort_column].nil? then
       params[:sort_column] = session[:licenses_sort_column]
    end
    if params[:sort_order].nil? && !session[:licenses_sort_order].nil? then
       params[:sort_order] = session[:licenses_sort_order]
    end

  end  
  
  # GET /licenses
  # GET /licenses.json
  def index
    restore_search if params[:commit] != "clear"
    @title = t('actions.listing') + " " + t('activerecord.models.licenses')
    @search_form_path = licenses_path

    @licenses = License.search_order(params[:license_name], params[:sort_column], params[:sort_order], params[:page])

    session[:licenses_page] = params[:page]
    session[:licenses_search_name] = params[:license_name]
    session[:licenses_sort_column] = params[:sort_column]
    session[:licenses_sort_order] = params[:sort_order]      
      
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @licenses }
    end
  end

  # GET /licenses/1
  # GET /licenses/1.json
  def show
    @title = t('actions.show') + " " + t('activerecord.models.license')

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
  end

  # POST /licenses
  # POST /licenses.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.license')
    @license = License.new(license_params)
    @license.user = current_user.email

    respond_to do |format|
      if @license.save
        format.html { redirect_to licenses_path, notice: t('flash.license.create.notice') }
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
    @license.user = current_user.email

    respond_to do |format|
      if @license.update(license_params)
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
    @license.user = current_user.email
    @license.destroy

    respond_to do |format|
      format.html { redirect_to licenses_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_license
      @license = License.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def license_params
      params.require(:license).permit(:license_type_id, :category_id, :description, :name, :text_license, :version, :flag_osi, :id, :notes, :similar_license_id)
    end

end
