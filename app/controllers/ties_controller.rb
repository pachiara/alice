class TiesController < ApplicationController
  def index
    
    @title = t('actions.listing') + " " + t('activerecord.models.ties')
    @products = Product.search(params[:product_name], params[:product_groupage], params[:page], 5)
    @components = Component.search(params[:component_name], params[:component_page], 5)
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
      @components = @product.components.order('name, version').paginate(page: params[:component_page], per_page: 10)   
      @products = Product.order('name, version').page(params[:page]).per_page(10)
    end

    if !params[:component_id].nil?  
      @component = Component.find(params[:component_id])
      @products = @component.products.order('name, version').paginate(page: params[:page], per_page: 10)   
      @components = Component.order('name, version').page(params[:component_page]).per_page(10)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product }
    end
  end
  
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.tie')
    require 'will_paginate/array'
    @search_form_path = product_ties_edit_path
    @product = Product.find(params[:product_id])
    
    if !params[:component_del].nil?
      @product.del_relation(params[:component_del])
    end
    if !params[:component_add].nil?
      @product.add_relation(params[:component_add])
    end

    @components_ties = @product.components.order('name, version').paginate(page: params[:component_ties_page], per_page: 6)
    @components = (Component.order('name, version').where("name like ?", "%#{params[:component_name]}%") - @product.components.order('name, version')).paginate(page: params[:component_page], per_page: 6)
         
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product }
    end    
  end    
  
  # DELETE /product/1/ties/destroy
  # DELETE /product/1/ties/destroy.json
  def destroy
    @product = Product.find(params[:product_id])
    @product.delete_components

    respond_to do |format|
      format.html { redirect_to product_ties_edit_url }
      format.json { head :no_content }
    end
  end

  # GET /product/1/ties/show
  # GET /product/1/ties/show.json
  def show
    @title = t('actions.show') + " " + t('activerecord.models.ties')
        
    @release = Release.find(params[:release_id])
    @components = @release.components.order('name, version').paginate(page: params[:page], per_page: 10)   

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @release }
    end
  end

end
