class TiesController < ApplicationController
  def index
    
    @title = t('actions.listing') + " " + t('activerecord.models.ties')
    @products = Product.order('created_at ASC').page(params[:page]).per_page(12)
    @components = Component.order('created_at ASC').page(params[:page]).per_page(12)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @products }
    end
    
    
  end
  
  def select
    @title = t('actions.listing') + " " + t('activerecord.models.ties')
    
    if !params[:product_id].nil?
      @product = Product.find(params[:product_id])
      @components = @product.components
      @products = Product.order('created_at ASC').page(params[:page]).per_page(12)
    end

    if !params[:component_id].nil?  
      @component = Component.find(params[:component_id])
      @products = @component.products
      @components = Component.order('created_at ASC').page(params[:page]).per_page(12)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product }
    end
  end
  
  
  
  
end
