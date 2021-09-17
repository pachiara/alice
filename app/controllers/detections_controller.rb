class DetectionsController < ApplicationController
  before_action :authenticate_user!, only: [:destroy]
  before_action :set_detection, only: [:show, :edit, :update, :destroy]

  def params
    request.parameters
  end
  
  def restore_search
    if params[:page].nil? && !session[:detections_page].nil? then
       params[:page] = session[:detections_page]
    end
  end

  # GET /detections
  # GET /detections.json
  def index
    restore_search if params[:commit] != "clear"
    @title = t('actions.listing') + " " + t('activerecord.models.detections')
    @detections = Detection.where(release_id: params[:release_id]).order('name ASC').page(params[:page]).per_page(12)
    @release = Release.find(params[:release_id])

    session[:detections_page] = params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @detections }
    end
  end

  # GET /detections/1
  # GET /detections/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @detection }
    end
  end

  # GET /detections/new
  # GET /detections/new.json
  def new
    @title = t('actions.new') + " " + t('activerecord.models.detection')
    @detection = Detection.new
    @detection.release_id = params[:release_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @detection }
    end
  end

  # GET /detections/1/edit
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.detection')
  end

  # POST /detections
  # POST /detections.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.detection')
    @detection = Detection.new(params[:detection])
    @detection.release_id = params[:release_id]
    respond_to do |format|
      if @detection.save
        format.html { redirect_to(detections_path + "?release_id=#{params[:release_id]}", notice: t('flash.detection.create.notice')) }
        format.json { render json: @detection, status: :created, location: @detection }
      else
        format.html { render action: "new" }
        format.json { render json: @detection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /detections/1
  # PUT /detections/1.json
  def update
    @title = t('actions.edit') + " " + t('activerecord.models.detection')

    respond_to do |format|
      if @detection.update(detection_params)
        format.html { redirect_to(detections_path + "?release_id=#{@detection.release_id}", notice: t('flash.detection.update.notice')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @detection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /detections/1
  # DELETE /detections/1.json
  def destroy
    @detection.user = current_user.email
    @detection.destroy

    respond_to do |format|
      format.html { redirect_to(detections_path + "?release_id=#{@detection.release_id}") }
      format.json { head :no_content }
    end
  end

  # GET /detections/validate_components
  def validate_components
    @title = t('actions.acquire') + " " + t('activerecord.models.components')
    @detection = Detection.find(params[:detection_id])
    @detection.validate_acquire

    respond_to do |format|
      format.html
    end
  end

  # POST /detections/acquire
  def acquire
    @detection = Detection.find(params[:detection_id])
    @detection.acquire

    respond_to do |format|
      @detection.update_attributes(acquired: true)
      format.html { redirect_to(detections_path + "?release_id=#{@detection.release_id}", notice: t('flash.detection.update.notice')) }
    end
  end

  # POST /detections/remote_detect
  # API
  def remote_detect
    # parametri
    # input:
    # 1 - nome/sigla prodotto
    # 2 - versione
    # 3 - nome rilevamento (facoltativo default "remote+time")
    # 4 - file delle licenze
    # output:
    # 0 ok rilevamento acquisito
    # 1 prodotto non trovato
    # 2 importazione non riuscita
    # 3 errori sui componenti del rilevamento
    # 4 nome rilevamento duplicato
    # 5 file licenses.xml vuoto
    # 7 file licenses.xml non ricevuto
    @name    = params[:product_name]
    @version = params[:product_version]
    # Controllo parametro product_name
    @product = Product.where('name = ?', "#{@name}").take
    if @product.nil?
      @result = {"result" => 1, "product" => "#{@name}", "version" => "#{@version}",
         "msg" => I18n.t("errors.messages.check.product_not_found", product_name: "#{@name}")}
    else
      # Controllo parametro product_version
      @release = Release.where('product_id = ? and version_name = ?', "#{@product.id}", "#{@version}").take
      if @release.nil?
        @release = Release.new()
        @release.product_id = @product.id
        @release.version_name = @version
        @release.license_id = License.where('name = "ariaspa"').take.id
        @release.sequential_number = @release.next_sequential_number
        @release.save
      else
        @release.update_attributes(check_result: nil, checked_at: nil, compatible_license_id: nil)
      end
      # Controllo parametro detection_name
      if @result.nil?
        if params[:detection_name].nil?
          @detection_name = "remote"+ Time.now.strftime("%Y-%d-%m-%H:%M:%S")
        else
          @detection_name = params[:detection_name]
        end
        if !@release.id.nil? and !(Detection.where('release_id = ? and name = ?', "#{@release.id}", "#{@detection_name}").take).nil?
          @result = {"result" => 4, "product" => "#{@name}", "version" => "#{@version}", "detection" => "#{@detection_name}",
             "msg" => I18n.t("errors.messages.r_detect.detection_name_taken") + detection_data}
        end
      end
    # Controllo parametro detection
      if @result.nil?
        if params[:detection].nil? ||
           !params[:detection].is_a?(ActiveSupport::HashWithIndifferentAccess) ||
           params[:detection][:xml].nil? ||
           !params[:detection][:xml].is_a?(ActionDispatch::Http::UploadedFile)
          @result = {"result" => 7, "product" => "#{@name}", "version" => "#{@version}", "detection" => "#{@detection_name}",
             "msg" => I18n.t("errors.messages.r_detect.licenses_file_missing") + detection_data}
        else
          @detection = Detection.new(params[:detection])
          @detection.name = @detection_name
          @detection.release_id = @release.id
        end
      end
    end

    respond_to do |format|
      if @result.nil?
        # Registro il rilevamento
        if @detection.save
          # Valido l'acquisizione
          @detection.validate_acquire
          if @detection.errors.full_messages.length > 0
            @ip=Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
            @link = detected_components_path(detection_id: @detection.id)
            if @detection.detected_components.length == 0 
              @result = {"result" => 5, "product" => "#{@name}", "version" => "#{@version}", "detection" => "#{@detection_name}",
                 "msg" => I18n.t("errors.messages.r_detect.licenses_file_empty") + detection_data + " - RILEVAMENTO ELIMINATO!"}
              @detection.destroy
            else
              require 'socket'
              @result = {"result" => 3, "product" => "#{@name}", "version" => "#{@version}", "detection" => "#{@detection_name}",
                 "msg" => I18n.t("errors.messages.r_detect.license_not_found") + detection_data + " link: http://#{@ip}:#{request.port}#{@link}"}
            end
          else
            # Acquisisco il rilevamento
            @detection.acquire
            # Modifico lo stato del rilevamento
            @detection.update_attributes(acquired: true)
            @result = {"result" => 0, "product" => "#{@name}", "version" => "#{@version}", "detection" => "#{@detection_name}",
               "msg" => I18n.t("errors.messages.r_detect.detection_acquired") + detection_data}
          end
        else
          @result = {"result" => 2, "product" => "#{@name}", "version" => "#{@version}", "detection" => "#{@detection_name}",
             "msg" => I18n.t("errors.messages.r_detect.detection_not_saved") + detection_data + " #{@detection.errors.full_messages[0]}"}
        end
      end
      format.html { render json: @result }
      format.json { render json: @result }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_detection
      @detection = Detection.find(params[:id])
    end

    def detection_data
      I18n.t("errors.messages.detection.detection_data", detection_name: "#{@detection_name}", product_name: "#{@name}", version: "#{@version}")
    end
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def detection_params
      ActionController::Parameters.new(params).require(:detection).permit(:name, :release_id, :xml, :created_at, :acquired)
    end

end
