class AboutController < ApplicationController
  def index
       @title = "Informazioni su Alice"
  end

  def alice
       @title = "Alice"
  end

  def lispa
       @title = "Azienda Regionale Innovazione Acquisti S.p.A."
  end
end
