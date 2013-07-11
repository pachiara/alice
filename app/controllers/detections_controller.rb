class DetectionsController < ApplicationController
  # GET /detections
  # GET /detections.json
  def index
    @title = t('actions.listing') + " " + t('activerecord.models.detections')
    @detections = Detection.where(product_id: params[:product_id]).order('created_at ASC').page(params[:page]).per_page(12)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @detections }
    end
  end

  # GET /detections/1
  # GET /detections/1.json
  def show
    @detection = Detection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @detection }
    end
  end

  # GET /detections/new
  # GET /detections/new.json
  def new
    @title = t('actions.new') + " " + t('activerecord.models.detection')
    @detection = Detection.new
    @detection.product_id = params[:product_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @detection }
    end
  end

  # GET /detections/1/edit
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.detection')
    @detection = Detection.find(params[:id])
  end

  # POST /detections
  # POST /detections.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.detection')
    @detection = Detection.new(params[:detection])
    @detection.product_id = params[:product_id]

    respond_to do |format|
      if @detection.save
        format.html { redirect_to(detections_path + "?product_id=#{params[:product_id]}", notice: t('flash.detection.create.notice')) }
        format.json { render json: @detection, status: :created, location: @detection }
      else
        format.html { render action: "new" }
        format.json { render json: @detection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /detections/1
  # PUT /detections/1.json
  def update
    @title = t('actions.edit') + " " + t('activerecord.models.detection')
    @detection = Detection.find(params[:id])

    respond_to do |format|
      if @detection.update_attributes(params[:detection])
        format.html { redirect_to(detections_path + "?product_id=#{@detection.product_id}", notice: t('flash.detection.update.notice')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @detection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /detections/1
  # DELETE /detections/1.json
  def destroy
    @detection = Detection.find(params[:id])
    @detection.destroy

    respond_to do |format|
      format.html { redirect_to(detections_path + "?product_id=#{@detection.product_id}") }
      format.json { head :no_content }
    end
  end
end
