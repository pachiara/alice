class ComponentsController < ApplicationController
  
    before_filter :authenticate_user!, only: [:edit, :update, :destroy]
  
  def restore_search
    if params[:page].nil? && !session[:components_page].nil? then
       params[:page] = session[:components_page]
    end
    if params[:component_name].nil? && !session[:components_search_name].nil? then
       params[:component_name] = session[:components_search_name]
    end
  end
  
  # GET /components
  # GET /components.json
  def index
    restore_search if params[:commit] != "clear"
    @title = t('actions.listing') + " " + t('activerecord.models.components')
    @search_form_path = components_path
    @components = Component.search(params[:component_name], params[:page])
    
    session[:components_page] = params[:page]
    session[:components_search_name] = params[:component_name]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @components }
    end
  end

  # GET /components/1
  # GET /components/1.json
  def show
    @title = t('actions.show') + " " + t('activerecord.models.component')
    @component = Component.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @component }
    end
  end

  # GET /components/new
  # GET /components/new.json
  def new
    @title = t('actions.new') + " " + t('activerecord.models.component')
    @component = Component.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @component }
    end
  end

  # GET /components/1/edit
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.component')
    @component = Component.find(params[:id])
  end

  # POST /components
  # POST /components.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.component')
    @component = Component.new(params[:component])

    respond_to do |format|
      if @component.save
        format.html { redirect_to components_path, notice: t('flash.component.create.notice') }
        format.json { render json: @component, status: :created, location: @component }
      else
        format.html { render action: "new" }
        format.json { render json: @component.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /components/1
  # PUT /components/1.json
  def update
    @title = t('actions.edit') + " " + t('activerecord.models.component')
    @component = Component.find(params[:id])

    respond_to do |format|
      if @component.update_attributes(params[:component])
        format.html { redirect_to(components_path, notice: t('flash.component.update.notice')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @component.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /components/1
  # DELETE /components/1.json
  def destroy
    @component = Component.find(params[:id])
    @component.destroy

    respond_to do |format|
      format.html { redirect_to components_url }
      format.json { head :no_content }
    end
  end
end
