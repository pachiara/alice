class ComponentsController < ApplicationController
  # GET /components
  # GET /components.json
  def index
    @title = t('actions.listing') + " " + t('activerecord.models.components')
    @components = Component.order('name, version').page(params[:page]).per_page(12)

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
        format.html { redirect_to @component, notice: t('flash.component.create.notice') }
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
        format.html { redirect_to @component, notice: t('flash.component.update.notice') }
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
