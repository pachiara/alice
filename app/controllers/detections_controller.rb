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
  def remote_detect
    # parametri
    # input: 
    # 1 - nome/sigla prodotto
    # 2 - versione
    # 3 - nome rilevamento (facoltativo default "remote+time")
    # 4 - file delle licenze
    # output:
    # 0 ok rilevamento acquisito 
    # 1 prodotto/versione non trovato
    # 2 importazione non riuscita
    # 3 errori nel rilevamento
    # 4 nome rilevamento duplicato
    # 7 file licenses.xml non ricevuto
    @name    = params[:product_name]
    @version = params[:product_version]
    # Controllo parametri product_name e product_version
    @product = Product.where('name LIKE ? and version LIKE ?', "%#{@name}%", "%#{@version}%").take
    if @product.nil?
      @result = "1 ** Errore ** Prodotto/versione non trovato - prodotto: #{@name} versione: #{@version}"
    end
    # Controllo parametro detection_name
    if @result.nil?
      if params[:detection_name].nil?
        @detection_name = "remote"+ Time.now.strftime("%Y-%d-%m-%H:%M:%S")
      else
        @detection_name = params[:detection_name]
      end
      if !(Detection.where('product_id = ? and name = ?', "#{@product.id}", "#{@detection_name}").take).nil?
        @result = "4 ** Errore ** Nome rilevamento duplicato - rilevamento: #{@detection_name}  prodotto: #{@name}  versione: #{@version}"
      end
    end
    # Controllo parametro detection
    if @result.nil?
      if params[:detection].nil? || 
         !params[:detection].is_a?(ActionController::Parameters) ||
         params[:detection][:xml].nil? ||
         !params[:detection][:xml].is_a?(ActionDispatch::Http::UploadedFile)
        @result = "7 ** Errore ** File licenses.xml non ricevuto - rilevamento: #{@detection_name}  prodotto: #{@name} versione: #{@version}"
      else  
        @detection = Detection.new(params[:detection])
        @detection.name = @detection_name 
        @detection.product_id = @product.id
      end
    end

    respond_to do |format|
      if @result.nil? 
        # Registro il rilevamento
        if @detection.save
          # Valido l'acquisizione
          @detection.validate_acquire
          if @detection.errors.full_messages.length > 0
            @result = "3 ** Errore ** Errori nel rilevamento: #{@detection_name} prodotto: #{@name} versione: #{@version}"
          else 
            # Acquisisco il rilevamento
            @detection.acquire
            # Modifico lo stato del rilevamento
            @detection.update_attributes(acquired: true)
            @result = "0 ** OK ** Rilevamento acquisito correttamente - rilevamento: #{@detection_name}  prodotto: #{@name} versione: #{@version}"
          end
        else
          @result = "2 ** Errore ** Importazione non riuscita - rilevamento: #{@detection_name}  prodotto: #{@name} versione: #{@version}"
        end
      end
      format.html { render json: @result }
      format.json { render json: @result }
    end
  end


  # POST /detections/remote_detect
  # API 
  def remote_check
    # parametri
    # input: 
    # 1 - nome/sigla prodotto
    # 2 - versione
    # output:
    # 0 controllo ok
    # 1 prodotto/versione non trovato
    # 5 impossibile eseguire il controllo
    # 6 KO sul controllo
    @name    = params[:product_name]
    @version = params[:product_version]
    @product = Product.where('name LIKE ? and version LIKE ?', "%#{@name}%", "%#{@version}%").take
    if @product.nil?
      @result = "1 ** Errore ** Prodotto/versione non trovato - prodotto: #{@name} versione: #{@version}"
    else
      if @product.precheck 
        @product.analyze_rules
        if @product.errors.full_messages.length > 0
          @result = "6 ** KO ** Prodotto: #{@name} versione: #{@version} - #{@product.errors.full_messages.last}"
        else
          @result = "0 ** OK ** Controllo ok prodotto: #{@name} versione: #{@version}"
        end
        # Aggiorno stato del prodotto
        @product.update_attributes(checked_at: Time.now)
      else
        @result = "5 ** Errore ** Prodotto: #{@name} versione: #{@version} - #{@product.errors.full_messages.last}"
        # Aggiorno stato del prodotto
        @product.update_attributes(result: nil, checked_at: nil, compatible_license_id: nil)
      end
    end
    respond_to do |format|
      format.html { render json: @result }
      format.json { render json: @result }
    end
  end


end
