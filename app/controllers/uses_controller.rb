class UsesController < ApplicationController
  # GET /uses
  # GET /uses.json
  def index
    @title = t('actions.listing') + " " + t('activerecord.models.uses')
    @uses = Use.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @uses }
    end
  end

  # GET /uses/1
  # GET /uses/1.json
  def show
    @title = t('actions.show') + " " + t('activerecord.models.use')
    @use = Use.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @use }
    end
  end

  # GET /uses/new
  # GET /uses/new.json
  def new
    @title = t('actions.new') + " " + t('activerecord.models.use')    
    @use = Use.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @use }
    end
  end

  # GET /uses/1/edit
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.use')    
    @use = Use.find(params[:id])
  end

  # POST /uses
  # POST /uses.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.use')    
    @use = Use.new(params[:use])

    respond_to do |format|
      if @use.save
        format.html { redirect_to @use, notice: t('flash.use.create.notice') }
        format.json { render json: @use, status: :created, location: @use }
      else
        format.html { render action: "new" }
        format.json { render json: @use.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /uses/1
  # PUT /uses/1.json
  def update
    @title = t('actions.edit') + " " + t('activerecord.models.use')    
    @use = Use.find(params[:id])

    respond_to do |format|
      if @use.update_attributes(params[:use])
        format.html { redirect_to @use, notice: t('flash.use.update.notice') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @use.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uses/1
  # DELETE /uses/1.json
  def destroy
    @use = Use.find(params[:id])
    @use.destroy

    respond_to do |format|
      format.html { redirect_to uses_url }
      format.json { head :no_content }
    end
  end
end
