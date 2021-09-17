class HomeController < ApplicationController
  def index
    @title = t('actions.management') + " " + t('activerecord.models.licenses')    
  end
end
