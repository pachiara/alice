class TiesController < ApplicationController
  def index
    
    @title = t('actions.listing') + " " + t('activerecord.models.ties')
    @products = Product.search(params[:product_name], params[:page])
    @components = Component.search(params[:component_name], params[:page])
    @search_form_path = ties_index_path
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @products }
    end
        
  end
  
  def select
    @title = t('actions.listing') + " " + t('activerecord.models.ties')
    @search_form_path = ties_index_path
        
    if !params[:product_id].nil?
      @product = Product.find(params[:product_id])
      @components = @product.components
      @products = Product.order('id ASC').page(params[:page]).per_page(12)
    end

    if !params[:component_id].nil?  
      @component = Component.find(params[:component_id])
      @products = @component.products
      @components = Component.order('id ASC').page(params[:page]).per_page(12)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product }
    end
  end
  
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.tie')
    
    @product = Product.find(params[:product_id])
    @components_ties = @product.components
    @components = Component.search(params[:component_name], params[:page])
    @search_form_path = product_ties_edit_path
    
    if !params[:component_del].nil?
      @product.del_relation(params[:component_del])
    end
    if !params[:component_add].nil?
      @product.add_relation(params[:component_add])
    end
         
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product }
    end    
  end    

end
