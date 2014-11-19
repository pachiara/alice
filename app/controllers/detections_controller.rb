class DetectionsController < ApplicationController
  # GET /detections
  # GET /detections.json
  def index
    @title = t('actions.listing') + " " + t('activerecord.models.detections')
    @detections = Detection.where(product_id: params[:product_id]).order('name ASC').page(params[:page]).per_page(12)
    @product = Product.find(params[:product_id])

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
    @detection.product_id = params[:product_id]

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
    @detection.product_id = params[:product_id]

    respond_to do |format|
      if @detection.save
        format.html { redirect_to(detections_path + "?product_id=#{params[:product_id]}", notice: t('flash.detection.create.notice')) }
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
        format.html { redirect_to(detections_path + "?product_id=#{@detection.product_id}", notice: t('flash.detection.update.notice')) }
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
      format.html { redirect_to(detections_path + "?product_id=#{@detection.product_id}") }
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
      format.html { redirect_to(detections_path + "?product_id=#{@detection.product_id}", notice: t('flash.detection.update.notice')) }
    end
  end

  # POST /detections/remote_check
  # API 
  def remote_check
    # parametri
    # input: 
    # 1 - nome/sigla prodotto
    # 2 - versione
    # 3 - file delle licenze
    # 4 - nome rilevamento (facoltativo se non esiste lo creo "remote+time")
    # output:
    # 1 - msg
    # 2 - nome
    # 3 - versione
    @msg     = []
    @name    = params[:name]
    @version = params[:version]
    @product = Product.order('name, version').where('name LIKE ? and version LIKE ?', "%#{@name}%", "%#{@version}%")
    @error   = false
    if @product.nil?
      # TODO se versione non esiste, crearla
      @msg.push("1 prodotto/versione non trovato-#{@name}-#{@version}")
      @error = true
    else
      @product = @product[0]
      if params[:detection].nil?
        @msg.push("7 file licenses.xml non ricevuto-#{@name}-#{@version}")
        @error = true
      else  
        if params[:detection_name].nil?
          @detection_name = "remote"+ Time.now.strftime("%Y-%d-%m-%H:%M:%S")
        else
          @detection_name = params[:detection_name]
        end
        @detection = Detection.new(params[:detection])
        @detection.name = @detection_name 
        @detection.product_id = @product.id
      end
    end
    # messaggi di errore:
    # "0 controllo ok"-"#{@name}"-"#{@version}"
    # "1 prodotto/versione non trovato"-"#{@name}"-"#{@version}"
    # "2 importazione non riuscita"-"#{@name}"-"#{@version}"
    # "3 validazione non riuscita"-"#{@name}"-"#{@version}"
    # "4 acquisizione non riuscita"-"#{@name}"-"#{@version}"
    # "5 impossibile eseguire il controllo"-"#{@name}"-"#{@version}"
    # "6 problemi sul controllo"-"#{@name}"-"#{@version}"
    # "7 file licenses.xml non ricevuto"-"#{@name}"-"#{@version}"
    respond_to do |format|
      # 1 - registro il rilevamento
      if !@error && @detection.save
        # 2 - valido l'acquisizione
        @detection.validate_acquire
        if @detection.errors.full_messages.length > 0
          @msg.push("3 validazione non riuscita-#{@name}-#{@version}")
        else 
          # 3 - acquisisco il rilevamento
          @detection.acquire
          if @detection.errors.full_messages.length > 0
            @msg.push("4 acquisizione non riuscita-#{@name}-#{@version}")
          else
            # 4 - modifico lo stato del rilevamento
            @detection.update_attributes(acquired: true)
            # 5 - eseguo il check del prodotto
            if @product.precheck 
              @product.analyze_rules
              if @product.errors.full_messages.length > 0
                @msg.push("6 problemi sul controllo-#{@name}-#{@version}")
              else
                @msg.push("0 controllo ok-#{@name}-#{@version}")
              end
            # 6 - Aggiorno stato del prodotto
            @product.update_attributes(checked_at: Time.now)
            else
              @msg.push("5 impossibile eseguire il controllo-#{@name}-#{@version}")
              # 6 - Aggiorno stato del prodotto
              @product.update_attributes(result: nil, checked_at: nil, compatible_license_id: nil)
            end
          end        
        end
      else
        @msg.push("2 importazione non riuscita-#{@name}-#{@version}-#{@detection.product_id}-#{@detection.name}-#{@detection.xml}-#{@error}")
      end
      format.html { render json: @msg }
      format.json { render json: @msg }
    end
  end

end
