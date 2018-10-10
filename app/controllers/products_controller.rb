class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def restore_search
    # Premuto tasto colonna
    if !params[:sort_column].nil? && params[:page].nil? then
      if params[:sort_column] != session[:products_sort_column] then
        params[:sort_order] = " ASC"
      else
        if session[:products_sort_order] == " ASC"
          params[:sort_order] = " DESC"
        else
          params[:sort_order] =  " ASC"
        end
      end
    end

    if params[:page].nil? && params[:restart_page].nil? && !session[:products_page].nil? then
       params[:page] = session[:products_page]
    end
    if params[:product_name].nil? && !session[:products_search_name].nil? then
       params[:product_name] = session[:products_search_name]
    end
    if params[:product_groupage].nil? && !session[:products_search_groupage].nil? then
       params[:product_groupage] = session[:products_search_groupage]
    end
    if params[:sort_column].nil? && !session[:products_sort_column].nil? then
       params[:sort_column] = session[:products_sort_column]
    end
    if params[:sort_order].nil? && !session[:products_sort_order].nil? then
       params[:sort_order] = session[:products_sort_order]
    end

  end

  # GET /products
  # GET /products.json
  def index
    restore_search if params[:commit] != "clear"
    @title = t('actions.listing') + " " + t('activerecord.models.products')
    @search_form_path = products_path

    @products = Product.search_order(params[:product_name], params[:product_groupage], params[:sort_column], params[:sort_order], params[:page])

    session[:products_page] = params[:page]
    session[:products_search_name] = params[:product_name]
    session[:products_search_groupage] = params[:product_groupage]
    session[:products_sort_column] = params[:sort_column]
    session[:products_sort_order] = params[:sort_order]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @products }
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @title = t('actions.messages.graphics')
    count_types
  end

  # GET /products/new
  # GET /products/new.json
  def new
    @title = t('actions.new') + " " + t('activerecord.models.product')
    @product = Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/1/edit
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.product')
  end

  # POST /products
  # POST /products.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.product')
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to(products_path, notice: t('flash.product.create.notice')) }
        format.json { render json: @product, status: :created, location: @product }
      else
        format.html { render action: "new" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update
    @title = t('actions.edit') + " " + t('activerecord.models.product')

    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to(products_path, notice: t('flash.product.update.notice')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end


  # POST /products/remote_create
  # API
  def remote_create
    # parametri
    # input:
    # 1 - nome/sigla prodotto (obbligatorio)
    # 2 - titolo (obbligatorio)
    # 3 - tipo uso (facoltativo, default 8="non definito")
    # 4 - descrizione lunga prodotto (facoltativo)
    # 5 - gruppo (facoltativo)
    # 6 - note (facoltativo)
    # output:
    # 0 prodotto creato
    # 1 impossibile creare il prodotto
    @product=Product.new
    @product.name = params[:name]
    @product.title = params[:title]
    @product.use_id = !params[:use_id].blank? ? params[:use_id] : 8
    @product.description = params[:description] || ""
    @product.groupage = params[:groupage] || ""
    @product.notes = params[:notes] || ""
    @product.save
    if @product.errors.full_messages.length > 0
      @result = {"result" => 1, "product" => "#{@product.name}", "msg" => @product.errors.full_messages.join(", ")}
    else
      @result = {"result" => 0, "product" => "#{@product.name}", "msg" => "Prodotto: #{@product.name} creato"}
    end
    respond_to do |format|
      format.html { render json: @result }
      format.json { render json: @result }
      format.xml { render xml: @result }
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
         "msg" => I18n.t("errors.messages.check.product_not_found", product_name: "#{@name}")}
    else
      if @version.nil?
        @version = @product.last_release.version_name
      end
      # Controllo parametro product_version
      @ip=Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
      @link = releases_path(product_id: @product.id)
      @release = Release.where('product_id = ? and version_name LIKE ?', "#{@product.id}", "#{@version}%").order('sequential_number desc').take
      if @release.nil?
        @result = {"result" => 2, "product" => "#{@name}", "version" => "#{@version}",
          "msg" => I18n.t("errors.messages.check.product_version_not_found", product_name: "#{@name}", version: "#{@version}") +
                   " link: http://#{@ip}:#{request.port}#{@link}"}
      else
        if @release.precheck
          @release.analyze_rules
          if @release.errors.full_messages.length > 0
            @result = {"result" => 6, "product" => "#{@name}", "version" => "#{@version}",
               "msg" => I18n.t("errors.messages.check.licenses_incompatibility", product_name: "#{@name}", version: "#{@release.version_name}") +
                      " - #{@release.errors.full_messages.last}" + "link: http://#{@ip}:#{request.port}#{@link}"}
          else
            @result = {"result" => 0, "product" => "#{@name}", "version" => "#{@version}",
               "msg" => I18n.t("infos.check.ok", product_name: "#{@name}", version: "#{@release.version_name}")}
          end
          # Aggiorno stato del prodotto
          @release.update_attributes(checked_at: Time.now)
        else
          @result = {"result" => 5, "product" => "#{@name}", "version" => "#{@version}",
             "msg" => I18n.t("infos.check.product_data", product_name: "#{@name}", version: "#{@release.version_name}") + 
                    "- #{@release.errors.full_messages.last}" + " link: http://#{@ip}:#{request.port}#{@link}"}

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
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:description, :name, :groupage, :notes, :title, :use_id, :last_release_version_name, :last_release_checked_at, :last_release_check_result)
    end

end
