class ReleasesController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update, :destroy]
  before_action :set_release, only: [:show, :edit, :update, :destroy]

  def restore_search
    if params[:page].nil? && !session[:releases_page].nil? then
       params[:page] = session[:releases_page]
    end
    if params[:product_name].nil? && !session[:products_search_name].nil? then
       params[:product_name] = session[:products_search_name]
    end
    if params[:groupage].nil? && !session[:products_search_groupage].nil? then
       params[:groupage] = session[:products_search_groupage]
    end
  end

  def count_types
    # Contatori tipi componente
    purchased = own = open_source = 0

    # Contatori tipi licenza
    license_types = Hash.new
    LicenseType.all.each do |license_type|
      license_types[license_type.description] = 0
    end
    license_types[t('activerecord.attributes.license_type.unidentified')] = 0

    # Contatori licenze
    licenses = Hash.new
    licenses[t('activerecord.attributes.license_type.unidentified')] = 0

    # Lettura componenti del prodotto e incremento contatori
    @release.components.each do |component|
      purchased += 1 if component.purchased
      own += 1 if component.own
      open_source += 1 if !component.purchased && !component.own
      if component.license.license_type.nil?
        license_types[t('activerecord.attributes.license_type.unidentified')] += 1
      else
        license_types[component.license.license_type.description] += 1
      end
      if component.license.nil?
        licenses[t('activerecord.attributes.license_type.unidentified')] += 1
      elsif licenses[component.license.description].nil?
        licenses[component.license.description] = 1
      else
        licenses[component.license.description] += 1
      end
    end

    # Creazione array tipi componente in json
    @component_types = Array.new
    @component_types.push({:item => t('activerecord.attributes.component.purchased'), :qty => purchased}) if purchased > 0
    @component_types.push({:item => t('activerecord.attributes.component.own'), :qty => own}) if own > 0
    @component_types.push({:item => "Open source", :qty => open_source}) if open_source > 0
    @component_types = @component_types.sort_by {|o| o[:qty]}.reverse.to_json

    # Creazione array tipi licenze in json
    @license_types = Array.new
    license_types.each do |data|
      @license_types.push({:item => data[0], :qty => data[1]}) if data[1] > 0
    end
    @license_types = @license_types.sort_by {|o| o[:qty]}.reverse.to_json

    # Creazione array licenze in json
    @licenses = Array.new
    licenses.each do |data|
      @licenses.push({:item => data[0], :qty => data[1]}) if data[1] > 0
    end
    @licenses = @licenses.sort_by {|o| o[:qty]}.reverse.to_json
  end

  # GET /releases
  # GET /releases.json
  def index
    @title = t('actions.listing') + " " + t('activerecord.models.releases')
    @product = Product.find(params[:product_id])
    @releases = Release.where(product_id: params[:product_id]).order('sequential_number DESC').page(params[:page]).per_page(12)
#    @releases = Release.search_release(params[:product_name], params[:groupage], params[:page])
  end

  # GET /releases/1
  # GET /releases/1.json
  def show
    @title = t('actions.messages.graphics')
    count_types
  end

  # GET /releases/new
  def new
    @title = t('actions.new') + " " + t('activerecord.models.release')
    @release = Release.new
    @release.product = Product.find(params[:product_id])
    @release.sequential_number = @release.next_sequential_number
    @release.license_id = License.where('name = "ariaspa"').take.id
  end

  # GET /releases/1/edit
  def edit
    @title = t('actions.edit') + " " + t('activerecord.models.release')
  end

  # POST /releases
  # POST /releases.json
  def create
    @title = t('actions.new') + " " + t('activerecord.models.release')
    @release = Release.new(release_params)
    @release.product = Product.find(params[:product_id])

    respond_to do |format|
      if @release.save
        format.html { redirect_to(releases_path + "?product_id=#{@release.product.id}", notice: t('flash.release.create.notice')) }
        format.json { render :show, status: :created, location: @release }
      else
        format.html { render :new }
        format.json { render json: @release.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /releases/1
  # PATCH/PUT /releases/1.json
  def update
    @title = t('actions.edit') + " " + t('activerecord.models.release')
    @release.user = current_user.email

    respond_to do |format|
      if @release.update(release_params)
        format.html { redirect_to(releases_path + "?product_id=#{@release.product.id}", notice: t('flash.release.update.notice')) }
        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: @release.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /releases/1
  # DELETE /releases/1.json
  def destroy
    @release.destroy
    respond_to do |format|
      format.html { redirect_to(releases_path + "?product_id=#{@release.product.id}", notice: t('flash.release.destroy.notice')) }

      format.json { head :no_content }
    end
  end

  # GET /releases/1/check
  def check
    @title = t('actions.check') + " " + t('actions.messages.compatibility')
    @release = Release.find(params[:release_id])
    if @release.precheck
      @release.analyze_rules
    else
      @release.check_result = nil
      @release.checked_at = nil
    end

    respond_to do |format|
      format.html
    end
  end

  # POST /releases/1/update_check
  def update_check
    @release = Release.find(params[:release_id])

    respond_to do |format|
      @release.update_attributes(check_result: params[:check_result], compatible_license_id: params[:compatible_license_id], checked_at: Time.now)
      format.html { redirect_to(releases_path + "?product_id=#{@release.product.id}", notice: t('flash.release.update.notice')) }
    end
  end

  # GET /releases/1/print_check
  def print_check
    @title = t('actions.messages.print_check')
    @release = Release.find(params[:release_id])

    @release.analyze_rules

    # Nella stampa devono apparire anche i componenti esclusi dal controllo
    @components = @release.components.order("name")
    @components_with_notes = Hash.new
    @licenses_with_notes = Hash.new
    @components.each do |component|
      @components_with_notes[component.name] = component.notes unless component.notes.blank?
      @licenses_with_notes[component.license.name] = component.license unless component.license.notes.blank?
    end
    @components_with_notes.sort
    @licenses_with_notes.sort

    respond_to do |format|
      format.pdf do
        render :pdf => @release.product.name.gsub(' ', '_'),
               :header => { :left => 'Alice',
                            :center => @title,
                            :right => t('actions.messages.classification'),
                            :line => true
                          },
               :footer => { :center => "#{t('actions.messages.date')} #{Time.now.strftime('%d/%m/%Y')}    #{t('actions.messages.hour')} #{Time.now.strftime('%H:%M')}",
                            :right => 'Pag. [page] / [topage]', :line => true },
               :show_as_html => params[:debug].present?
      end
    end
  end


  # GET /products/1/print
  def print
    @title = t('actions.messages.graphics')
    @release = Release.find(params[:release_id])
    count_types
    @components = @release.components.order("name")

    respond_to do |format|
      format.pdf do
        render :pdf => @release.product.name.gsub(' ', '_'),
               :lowquality =>  true,
               :header => { :left => 'Alice',
                            :center => @title,
                            :right => t('actions.messages.classification'),
                            :line => true,
                            :font_size => 10
                          },
               :footer => { :center => "#{t('actions.messages.date')} #{Time.now.strftime('%d/%m/%Y')}    #{t('actions.messages.hour')} #{Time.now.strftime('%H:%M')}",
                            :right => 'Pag. [page] / [topage]',
                            :line => true,
                            :font_size => 10
                          },
               :print_media_type => true,
               :show_as_html => params[:debug].present?
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_release
      @release = Release.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def release_params
      params.require(:release).permit(:product_id, :version_name, :sequential_number, :license_id, :check_result, :checked_at, :compatible_license_id, :notes)
    end
end
