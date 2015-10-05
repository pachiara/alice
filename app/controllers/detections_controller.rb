class DetectionsController < ApplicationController
  
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
<<<<<<< HEAD
    @detections = Detection.where(product_id: params[:product_id]).order('name ASC').page(params[:page]).per_page(12)
    @product = Product.find(params[:product_id])
=======
    @detections = Detection.where(release_id: params[:release_id]).order('name ASC').page(params[:page]).per_page(12)
    @release = Release.find(params[:release_id])

    session[:detections_page] = params[:page]
>>>>>>> v2.branch

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @detections }
    end
  end

  # GET /detections/1
  # GET /detections/1.json
  def show
    @detection = Detection.find(params[:id])

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
    @detection = Detection.find(params[:id])
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
    @detection = Detection.find(params[:id])

    respond_to do |format|
      if @detection.update_attributes(params[:detection])
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
    @detection = Detection.find(params[:id])
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
         "msg" => "** Errore ** Prodotto non trovato - prodotto: #{@name}"}
    else
      # Controllo parametro product_version
      @release = Release.where('product_id = ? and version_name = ?', "#{@product.id}", "#{@version}").take
      if @release.nil?
        @release = Release.new()
        @release.product_id = @product.id
        @release.version_name = @version
        @release.license_id = License.where('name = "lispa"').take.id
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
             "msg" => "** Errore ** Nome rilevamento duplicato - rilevamento: #{@detection_name}  prodotto: #{@name}  versione: #{@version}"}
        end
      end
      # Controllo parametro detection
      if @result.nil?
        if params[:detection].nil? || 
           !params[:detection].is_a?(ActionController::Parameters) ||
           params[:detection][:xml].nil? ||
           !params[:detection][:xml].is_a?(ActionDispatch::Http::UploadedFile)
          @result = {"result" => 7, "product" => "#{@name}", "version" => "#{@version}", "detection" => "#{@detection_name}",
             "msg" => "** Errore ** File licenses.xml non ricevuto - rilevamento: #{@detection_name}  prodotto: #{@name} versione: #{@version}"}
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
            if @detection.errors.full_messages[0].include? "Nessun componente"
              @result = {"result" => 5, "product" => "#{@name}", "version" => "#{@version}", "detection" => "#{@detection_name}",
                 "msg" => "** Errore ** File licenses.xml vuoto - rilevamento: #{@detection_name}  prodotto: #{@name} versione: #{@version}" +
                  " - RILEVAMENTO ELIMINATO!"}
              @detection.destroy
            else
              require 'socket'  
              @result = {"result" => 3, "product" => "#{@name}", "version" => "#{@version}", "detection" => "#{@detection_name}",
                 "msg" => "** Errore ** Errori sui componenti del rilevamento: #{@detection_name} prodotto: #{@name} versione: #{@version}",
                 "link" => "http://#{@ip}:#{request.port}#{@link}"}
            end
          else 
            # Acquisisco il rilevamento
            @detection.acquire
            # Modifico lo stato del rilevamento
            @detection.update_attributes(acquired: true)
            @result = {"result" => 0, "product" => "#{@name}", "version" => "#{@version}", "detection" => "#{@detection_name}",
               "msg" => "** OK ** Rilevamento acquisito correttamente - rilevamento: #{@detection_name}  prodotto: #{@name} versione: #{@version}"}
          end
        else
          @result = {"result" => 2, "product" => "#{@name}", "version" => "#{@version}", "detection" => "#{@detection_name}",
             "msg" => "** Errore ** Importazione non riuscita - rilevamento: #{@detection_name}  prodotto: #{@name} versione: #{@version}"}
        end
      end
      format.html { render json: @result }
      format.json { render json: @result }
    end
  end


  # POST /detections/remote_check
  # API 
  def remote_check
    # parametri
    # input: 
    # 1 - nome/sigla prodotto
    # 2 - versione
    # output:
    # 0 controllo ok
    # 1 prodotto non trovato
    # 2 versione non trovata
    # 5 impossibile eseguire il controllo
    # 6 KO sul controllo
    @name    = params[:product_name]
    @version = params[:product_version]
    @product = Product.where('name = ?', "#{@name}").take
    if @product.nil?
      @result = {"result" => 1, "product" => "#{@name}",
         "msg" => "** Errore ** Prodotto non trovato - prodotto: #{@name}"}
    else
      if @version.nil?
        @version = @product.last_release.version_name
      end
      # Controllo parametro product_version
      @ip=Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
      @link = releases_path(product_id: @product.id)
      @release = Release.where('product_id = ? and version_name LIKE ?', "#{@product.id}", "%#{@version}%").take
      if @release.nil?
        @result = {"result" => 2, "product" => "#{@name}", "version" => "#{@version}",
           "msg" => "** Errore ** Versione del prodotto inesistente - prodotto: #{@name} versione: #{@version}",
           "link" => "http://#{@ip}:#{request.port}#{@link}"}
      else
        if @release.precheck 
          @release.analyze_rules
          if @release.errors.full_messages.length > 0
            @result = {"result" => 6, "product" => "#{@name}", "version" => "#{@version}",
               "msg" => "6 ** KO ** Prodotto: #{@name} versione: #{@version} - #{@release.errors.full_messages.last}",
               "link" => "http://#{@ip}:#{request.port}#{@link}"}
          else
            @result = {"result" => 0, "product" => "#{@name}", "version" => "#{@version}",
               "msg" => "** OK ** Controllo ok prodotto: #{@name} versione: #{@version}"}
          end
          # Aggiorno stato del prodotto
          @release.update_attributes(checked_at: Time.now)
        else
          @result = {"result" => 5, "product" => "#{@name}", "version" => "#{@version}",
             "msg" => "** Errore ** Prodotto: #{@name} versione: #{@version} - #{@release.errors.full_messages.last}",
             "link" => "http://#{@ip}:#{request.port}#{@link}"}

          # Aggiorno stato del prodotto
          @release.update_attributes(check_result: nil, checked_at: nil, compatible_license_id: nil)
        end
      end
    end
    respond_to do |format|
      format.html { render json: @result }
      format.json { render json: @result }
      format.xml { render xml: @result }
    end
  end


end
