class RulesController < ApplicationController
  # GET /rules
  # GET /rules.json
  def index
    @title = t('actions.listing') + " " + t('activerecord.models.rules')
    @rules = Rule.order('created_at ASC').page(params[:page]).per_page(10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rules }
    end
  end

  # GET /rules/1
  # GET /rules/1.json
  def show
    @title = t('actions.show') + " " + t('activerecord.models.rule')
    @rule = Rule.find(params[:id])

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
    @rule = Rule.find(params[:id])
  end

  # POST /rules
  # POST /rules.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.rule')
    @rule = Rule.new(params[:rule])

    respond_to do |format|
      if @rule.save
        format.html { redirect_to @rule, notice: t('flash.rule.create.notice') }
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
    @rule = Rule.find(params[:id])

    respond_to do |format|
      if @rule.update_attributes(params[:rule])
        format.html { redirect_to @rule, notice: t('flash.rule.update.notice') }
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
    @rule = Rule.find(params[:id])
    @rule.destroy

    respond_to do |format|
      format.html { redirect_to rules_url }
      format.json { head :no_content }
    end
  end
end
