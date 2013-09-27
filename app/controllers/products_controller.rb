require 'ruleby'
require 'json'

class ProductsController < ApplicationController
  include Ruleby

  def restore_search
    if params[:page].nil? && !session[:products_page].nil? then
       params[:page] = session[:products_page]
    end
    if params[:product_name].nil? && !session[:products_search_name].nil? then
       params[:product_name] = session[:products_search_name]
    end
  end
  
  def count_types
    # Contatori tipi componente
    purchased = own = open_source = 0
    
    # Contatori tipi licenza
    license_types = Hash.new
    LicenseType.all.each do |license_type|
      license_types[license_type.description] = 0
    end
    license_types[t('activerecord.attributes.license_type.unidentified')] = 0

    # Contatori licenze
    licenses = Hash.new
    licenses[t('activerecord.attributes.license_type.unidentified')] = 0

    # Lettura componenti del prodotto e incremento contatori
    @product.components.each do |component|
      purchased += 1 if component.purchased
      own += 1 if component.own
      open_source += 1 if !component.purchased && !component.own
      if component.license.license_type.nil? 
        license_types[t('activerecord.attributes.license_type.unidentified')] += 1
      else
        license_types[component.license.license_type.description] += 1
      end  
      if component.license.nil?
        licenses[t('activerecord.attributes.license_type.unidentified')] += 1
      elsif licenses[component.license.description].nil?
        licenses[component.license.description] = 1
      else
        licenses[component.license.description] += 1
      end
    end
    
    # Creazione array tipi componente in json
    @component_types = Array.new
    @component_types.push({:tipo => t('activerecord.attributes.component.purchased'), :qta => purchased}) if purchased > 0
    @component_types.push({:tipo => t('activerecord.attributes.component.own'), :qta => own}) if own > 0
    @component_types.push({:tipo => "Open source", :qta => open_source}) if open_source > 0
    @component_types = @component_types.sort_by {|o| o[:qta]}.reverse.to_json

    # Creazione array tipi licenze in json
    @license_types = Array.new
    license_types.each do |data|
      @license_types.push({:tipo => data[0], :qta => data[1]}) if data[1] > 0
    end
    @license_types = @license_types.sort_by {|o| o[:qta]}.reverse.to_json
    
    # Creazione array licenze in json
    @licenses = Array.new
    licenses.each do |data|
      @licenses.push({:tipo => data[0], :qta => data[1]}) if data[1] > 0
    end
    @licenses = @licenses.sort_by {|o| o[:qta]}.reverse.to_json
  end
  
  
  # GET /products
  # GET /products.json
  def index
    restore_search if params[:commit] != "clear"
    @title = t('actions.listing') + " " + t('activerecord.models.products')
    @search_form_path = products_path
    @products = Product.search(params[:product_name], params[:page])

    session[:products_page] = params[:page]
    session[:products_search_name] = params[:product_name]

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
  
  # GET /products/1/print
  def print
    @title = t('actions.messages.graphics')
    @product = Product.find(params[:product_id])
    count_types
        
    respond_to do |format|
      format.pdf do
        render :pdf => "graphics"
      end
    end
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
  
    
  # GET /products/1/check
  def check
    @title = t('actions.check') + " " + t('activerecord.models.components')
    @product = Product.find(params[:product_id])
    engine :engine do |e|
      LicenseRulebook.new(e).rules
      e.assert @product
      @components = @product.components.where(:own => false, :purchased => false )
      @components.each do |component|
        e.assert component
      end
      e.match
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

  
end
