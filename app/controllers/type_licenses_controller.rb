class TypeLicensesController < ApplicationController
  # GET /type_licenses
  # GET /type_licenses.json
  def index
    @title = t('actions.listing') + " " + t('activerecord.models.type_licenses')
    @type_licenses = TypeLicense.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @type_licenses }
    end
  end

  # GET /type_licenses/1
  # GET /type_licenses/1.json
  def show
    @title = t('actions.show') + " " + t('activerecord.models.type_license')
    @type_license = TypeLicense.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @type_license }
    end
  end

  # GET /type_licenses/new
  # GET /type_licenses/new.json
  def new
    @title = t('actions.new') + " " + t('activerecord.models.type_license')
    @type_license = TypeLicense.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @type_license }
    end
  end

  # GET /type_licenses/1/edit
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.type_license')
    @type_license = TypeLicense.find(params[:id])
  end

  # POST /type_licenses
  # POST /type_licenses.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.type_license')
    @type_license = TypeLicense.new(params[:type_license])

    respond_to do |format|
      if @type_license.save
        format.html { redirect_to @type_license, notice: 'Type license was successfully created.' }
        format.json { render json: @type_license, status: :created, location: @type_license }
      else
        format.html { render action: "new" }
        format.json { render json: @type_license.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /type_licenses/1
  # PUT /type_licenses/1.json
  def update
    @title = t('actions.edit') + " " + t('activerecord.models.type_license')
    @type_license = TypeLicense.find(params[:id])

    respond_to do |format|
      if @type_license.update_attributes(params[:type_license])
        format.html { redirect_to @type_license, notice: 'Type license was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @type_license.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /type_licenses/1
  # DELETE /type_licenses/1.json
  def destroy
    @type_license = TypeLicense.find(params[:id])
    @type_license.destroy

    respond_to do |format|
      format.html { redirect_to type_licenses_url }
      format.json { head :no_content }
    end
  end
end
