class RulesController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  before_action :set_rule, only: [:show, :edit, :update, :destroy]

  # GET /rules
  # GET /rules.json
  def index
    @title = t('actions.listing') + " " + t('activerecord.models.rules')
    @rules = Rule.order('name').page(params[:page]).per_page(10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rules }
    end
  end

  # GET /rules/1
  # GET /rules/1.json
  def show
    @title = t('actions.show') + " " + t('activerecord.models.rule')

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rule }
    end
  end

  # GET /rules/new
  # GET /rules/new.json
  def new
    @title = t('actions.new') + " " + t('activerecord.models.rule')
    @rule = Rule.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rule }
    end
  end

  # GET /rules/1/edit
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.rule')
  end

  # POST /rules
  # POST /rules.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.rule')
    @rule = Rule.new(rule_params)

    respond_to do |format|
      if @rule.save
        format.html { redirect_to rules_path, notice: t('flash.rule.create.notice') }
        format.json { render json: @rule, status: :created, location: @rule }
      else
        format.html { render action: "new" }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rules/1
  # PUT /rules/1.json
  def update
    @title = t('actions.edit') + " " + t('activerecord.models.rule')

    respond_to do |format|
      if @rule.update(rule_params)
        format.html { redirect_to rules_path, notice: t('flash.rule.update.notice') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rules/1
  # DELETE /rules/1.json
  def destroy
    @rule.destroy

    respond_to do |format|
      format.html { redirect_to rules_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rule
      @rule = Rule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rule_params
      params.require(:rule).permit(:name, :license_id, :plus)
    end


end
