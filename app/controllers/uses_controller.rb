class UsesController < ApplicationController
  before_action :set_use, only: [:show, :edit, :update, :destroy]

  # GET /uses
  # GET /uses.json
  def index
    @title = t('actions.listing') + " " + t('activerecord.models.uses')
    @uses = Use.order('name')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @uses }
    end
  end

  # GET /uses/1
  # GET /uses/1.json
  def show
    @title = t('actions.show') + " " + t('activerecord.models.use')

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
  end

  # POST /uses
  # POST /uses.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.use')
    @use = Use.new(use_params)

    respond_to do |format|
      if @use.save
        format.html { redirect_to uses_path, notice: t('flash.use.create.notice') }
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

    respond_to do |format|
      if @use.update(use_params)
        format.html { redirect_to uses_path, notice: t('flash.use.update.notice') }
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
    @use.destroy

    respond_to do |format|
      format.html { redirect_to uses_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_use
      @use = Use.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def use_params
      params.require(:use).permit(:description, :name)
    end

end
