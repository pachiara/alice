class LicenseTypesController < ApplicationController
  # GET /license_types
  # GET /license_types.json
  def index
    @title = t('actions.listing') + " " + t('activerecord.models.license_types')
    @license_types = LicenseType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @license_types }
    end
  end

  # GET /license_types/1
  # GET /license_types/1.json
  def show
    @title = t('actions.show') + " " + t('activerecord.models.license_type')
    @license_type = LicenseType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @license_type }
    end
  end

  # GET /license_types/new
  # GET /license_types/new.json
  def new
    @title = t('actions.new') + " " + t('activerecord.models.license_type')
    @license_type = LicenseType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @license_type }
    end
  end

  # GET /license_types/1/edit
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.license_type')
    @license_type = LicenseType.find(params[:id])
  end

  # POST /license_types
  # POST /license_types.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.license_type')
    @license_type = LicenseType.new(params[:license_type])

    respond_to do |format|
      if @license_type.save
        format.html { redirect_to @license_type, notice: t('flash.license_type.create.notice') }
        format.json { render json: @license_type, status: :created, location: @license_type }
      else
        format.html { render action: "new" }
        format.json { render json: @license_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /license_types/1
  # PUT /license_types/1.json
  def update
    @title = t('actions.edit') + " " + t('activerecord.models.license_type')
    @license_type = LicenseType.find(params[:id])

    respond_to do |format|
      if @license_type.update_attributes(params[:license_type])
        format.html { redirect_to @license_type, notice: t('flash.license_type.update.notice') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @license_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /license_types/1
  # DELETE /license_types/1.json
  def destroy
    @license_type = LicenseType.find(params[:id])
    @license_type.destroy

    respond_to do |format|
      format.html { redirect_to license_types_url }
      format.json { head :no_content }
    end
  end
end
