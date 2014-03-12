class AboutController < ApplicationController
  def index
       @title = "Informazioni su Alice"
  end

  def alice
       @title = "Alice"
  end

  def lispa
       @title = "Lombardia Informatica S.p.A."
  end
end
