class DetectedComponentsController < ApplicationController
  before_filter :authenticate_user!, only: [:edit, :update, :destroy]
  before_action :set_detected_component, only: [:show, :edit, :update, :destroy]

  def restore_search
    if params[:page].nil? && !session[:detected_components_page].nil? then
       params[:page] = session[:detected_components_page]
    end
  end

  # GET /detected_components
  # GET /detected_components.json
  def index
    restore_search if params[:commit] != "clear"
    @title = t('actions.listing') + " " + t('activerecord.models.detected_components')
    @detected_components = DetectedComponent.where(detection_id: params[:detection_id]).order('name ASC').page(params[:page]).per_page(10)
    @release = Detection.find(params[:detection_id]).release

    session[:detected_components_page] = params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @detected_components }
    end
  end

  # GET /detected_components/1
  # GET /detected_components/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @detected_component }
    end
  end

  # GET /detected_components/new
  # GET /detected_components/new.json
  def new
    @title = t('actions.new') + " " + t('activerecord.models.detected_component')
    @detected_component = DetectedComponent.new
    @detected_component.detection = Detection.find(params[:detection_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @detected_component }
    end
  end

  # GET /detected_components/1/edit
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.detected_component')
    @licenses = @detected_component.search_licenses(@detected_component.license_name, @detected_component.license_version)
  end

  # POST /detected_components
  # POST /detected_components.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.detected_component')
    @detected_component = DetectedComponent.new(detected_component_params)
    @detected_component.detection = Detection.find(params[:detection_id])

    respond_to do |format|
      if @detected_component.save
        format.html { redirect_to(detected_components_path + "?detection_id=#{@detected_component.detection.id}", notice: t('flash.detected_component.create.notice')) }
        format.json { render json: @detected_component, status: :created, location: @detected_component }
      else
        format.html { render action: "new" }
        format.json { render json: @detected_component.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /detected_components/1
  # PUT /detected_components/1.json
  def update
    @title = t('actions.edit') + " " + t('activerecord.models.detected_component')
    @detected_component.user = current_user.email

    respond_to do |format|
      if @detected_component.update(detected_component_params)
        format.html { redirect_to(detected_components_path + "?detection_id=#{@detected_component.detection.id}", notice: t('flash.detected_component.update.notice')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @detected_component.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /detected_components/1
  # DELETE /detected_components/1.json
  def destroy
    @detected_component.user = current_user.email
    @detected_component.destroy

    respond_to do |format|
      format.html { redirect_to(detected_components_path + "?detection_id=#{@detected_component.detection.id}")}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_detected_component
      @detected_component = DetectedComponent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def detected_component_params
      params.require(:detected_component).permit(:component_id, :license_id, :license_name, :license_version, :name, :version, :own, :purchased)
    end

end
