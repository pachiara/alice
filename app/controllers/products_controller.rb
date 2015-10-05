class ProductsController < ApplicationController

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
<<<<<<< HEAD
  end
  
  def order_search
    case params[:order]
    when "name"
      if session[:down_name].nil?
        session[:down_name] = true
      end
      @down_name = session[:down_name]
      if session[:products_page] == params[:page] then
        @down_name = !session[:down_name]
        session[:down_name] = @down_name      
      end 
      if @down_name 
        @order = "name DESC, version DESC"
      else
        @order = "name ASC, version ASC"
      end
      @class_name = "btn btn-mini btn-info" 
      when "groupage"
      if session[:down_groupage].nil?
        session[:down_groupage] = true
      end
      @down_groupage = session[:down_groupage]
      if session[:products_page] == params[:page] then
        @down_groupage = !session[:down_groupage]
        session[:down_groupage] = @down_groupage
      end         
      if @down_groupage
        @order = "groupage DESC"
      else
        @order = "groupage ASC"
      end  
      @class_groupage = "btn btn-mini btn-info"
    end
    return @order  
  end
  
  def precheck
    result = true
    if @product.license.nil?
      @product.errors.add("Impossibile eseguire il controllo:", "specificare una licenza per il prodotto.")
      result = false
    end
    if @product.components.empty? 
      @product.errors.add("Impossibile eseguire il controllo:", "il prodotto non ha componenti.")
      result = false
    else
      @product.components.each do |component|
        if component.license.license_type.nil?
          @product.errors.add("Impossibile eseguire il controllo:", 
           "specificare tipo licenza per licenza #{component.license.name} versione #{component.license.version}.")
          result = false
        end
      end
    end
    return result
  end
  
  def analyze_rules
    @components = @product.components.where(:own => false, :leave_out => false )
    # Inizializzazione
    @product.compatible_license = License.where("name=?", "public").first
    @product.result = true
    @product.addInfo("Licenza compatibilità componenti iniziale:",
                     " #{@product.compatible_license.name} #{@product.compatible_license.version}")

    engine :engine do |e|
      CompatibilityRulebook.new(e).rules
      e.assert @product
      @components.each do |component|
        e.assert component
      end
      e.match
    end

    engine :engine do |e|
      CheckRulebook.new(e).rules
      e.assert @product
      @components.each do |component|
        e.assert component
      end
      e.match
    end
  end
  
  def count_types
    # Contatori tipi componente
    purchased = own = open_source = 0
    
    # Contatori tipi licenza
    license_types = Hash.new
    LicenseType.all.each do |license_type|
      license_types[license_type.description] = 0
=======
    if params[:sort_column].nil? && !session[:products_sort_column].nil? then
       params[:sort_column] = session[:products_sort_column]
>>>>>>> v2.branch
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
    @product = Product.find(params[:id])
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
    @product = Product.find(params[:id])
  end

  # POST /products
  # POST /products.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.product')
    @product = Product.new(params[:product])

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
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(params[:product])
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
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end
  
<<<<<<< HEAD
    
  # GET /products/1/check
  def check
    @title = t('actions.check') + " " + t('actions.messages.compatibility')
    @product = Product.find(params[:product_id])
    if precheck 
      analyze_rules
    else
      @product.result = nil
      @product.checked_at = nil
    end

    respond_to do |format|
      format.html
    end
  end
  
  # POST /products/1/update_check
  def update_check
    @product = Product.find(params[:product_id])
    
    respond_to do |format|
      @product.update_attributes(result: params[:result], compatible_license_id: params[:compatible_license_id], checked_at: Time.now)
      format.html { redirect_to(products_path, notice: t('flash.product.update.notice')) }
    end
  end

  # GET /products/1/print_check
  def print_check
    @title = t('actions.messages.print_check')
    @product = Product.find(params[:product_id])

    analyze_rules 
    
    # Nella stampa devono apparire anche i componenti esclusi dal controllo 
    @components = @product.components.order("name")
    @components_with_notes = Hash.new
    @licenses_with_notes = Hash.new
    @components.each do |component| 
      @components_with_notes[component.name] = component.notes unless component.notes.blank?  
      @licenses_with_notes[component.license.name] = component.license unless component.license.notes.blank?  
    end
    @components_with_notes.sort
    @licenses_with_notes.sort
        
    respond_to do |format|
      format.pdf do
        render :pdf => @product.name.gsub(' ', '_'),
               :header => { :left => 'Alice',
                            :center => @title,
                            :right => t('actions.messages.classification'),
                            :line => true
                          },
               :footer => { :center => "#{t('actions.messages.date')} #{Time.now.strftime('%d/%m/%Y')}    #{t('actions.messages.hour')} #{Time.now.strftime('%H:%M')}",
                            :right => 'Pag. [page] / [topage]', :line => true },
               :show_as_html => params[:debug].present?
      end
    end
  end
  
end
=======
end
>>>>>>> v2.branch
