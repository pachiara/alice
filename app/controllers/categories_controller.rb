class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  # GET /categories
  # GET /categories.json
  def index
    @title = t('actions.listing') + " " + t('activerecord.models.categories')
    @categories = Category.order('name').page(params[:page]).per_page(10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    @title = t('actions.show') + " " + t('activerecord.models.category')

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @category }
    end
  end

  # GET /categories/new
  # GET /categories/new.json
  def new
    @title = t('actions.new') + " " + t('activerecord.models.category')
    @category = Category.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @category }
    end
  end

  # GET /categories/1/edit
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.category')
  end

  # POST /categories
  # POST /categories.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.category')
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to categories_path, notice: t('flash.category.create.notice') }
        format.json { render json: @category, status: :created, location: @category }
      else
        format.html { render action: "new" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.json
  def update
    @title = t('actions.edit') + " " + t('activerecord.models.category')

    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to categories_path, notice:  t('flash.category.update.notice') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy

    respond_to do |format|
      format.html { redirect_to categories_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:description, :name)
    end

end
