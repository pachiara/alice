class LicensesController < ApplicationController
  # GET /licenses
  # GET /licenses.json
  def index
    @title = t('actions.listing') + " " + t('activerecord.models.licenses')
    #@licenses = License.all
    @licenses = License.order('created_at ASC').page(params[:page]).per_page(15)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @licenses }
    end
  end

  # GET /licenses/1
  # GET /licenses/1.json
  def show
    @title = t('actions.show') + " " + t('activerecord.models.license')
    @license = License.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @license }
    end
  end

  # GET /licenses/1.text
  def download
    @license = License.find(params[:license_id])

    if @license.text_license.size > 0
    send_data @license.text_license,
              :filename => @license.name+".txt",
              :type => "application/text"
    else
      respond_to do |format|
        format.html { render action: "show" }
        format.json { render json: @license }
      end
    end
    
  end

  # GET /licenses/new
  # GET /licenses/new.json
  def new
    @title = t('actions.new') + " " + t('activerecord.models.license')
    @license = License.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @license }
    end
  end

  # GET /licenses/1/edit
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.license')
    @license = License.find(params[:id])
  end

  # POST /licenses
  # POST /licenses.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.license')
    @license = License.new(params[:license])

    respond_to do |format|
      if @license.save
        format.html { redirect_to @license, notice: t('flash.license.create.notice') }
        format.json { render json: @license, status: :created, location: @license }
      else
        format.html { render action: "new" }
        format.json { render json: @license.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /licenses/1
  # PUT /licenses/1.json
  def update
    @title = t('actions.edit') + " " + t('activerecord.models.license')
    @license = License.find(params[:id])

    respond_to do |format|
      if @license.update_attributes(params[:license])
        format.html { redirect_to licenses_url, notice:  t('flash.license.update.notice') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @license.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /licenses/1
  # DELETE /licenses/1.json
  def destroy
    @license = License.find(params[:id])
    @license.destroy

    respond_to do |format|
      format.html { redirect_to licenses_url }
      format.json { head :no_content }
    end
  end
end
