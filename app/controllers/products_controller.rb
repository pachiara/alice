class ProductsController < ApplicationController

  def restore_search
    if params[:page].nil? && !session[:products_page].nil? then
       params[:page] = session[:products_page]
    end
    if params[:product_name].nil? && !session[:products_search_name].nil? then
       params[:product_name] = session[:products_search_name]
    end
    if params[:product_groupage].nil? && !session[:products_search_groupage].nil? then
       params[:product_groupage] = session[:products_search_groupage]
    end
  end
  
  def order_search
    @order_search = params[:order_search]
    case @order_search
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
    end
    return @order  
  end
  
  # GET /products
  # GET /products.json
  def index
    restore_search if params[:commit] != "clear"
    @title = t('actions.listing') + " " + t('activerecord.models.products')
    @search_form_path = products_path
    
    if params[:order_search].nil? || params[:order_search].empty? then
      @products = Product.search(params[:product_name], params[:product_groupage], params[:page])
    else
      @products = Product.search_order(order_search, params[:page])
    end

    session[:products_page] = params[:page]
    session[:products_search_name] = params[:product_name]
    session[:products_search_groupage] = params[:product_groupage]

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
  
end