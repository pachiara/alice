class SpyMailer < ApplicationMailer
  def detection_destroyed_email(detection)
    @detection = detection
    mail(to: ALICE['spy_mail_list'], subject: "Cancellazione di un rilevamento")
  end  
  def detected_component_email(detected_component, license_name)
    @detected_component = detected_component
    @license_name = license_name
    mail(to: ALICE['spy_mail_list'], subject: "Modifica manuale ad un componente rilevato")
  end  
  def detected_component_destroyed_email(detected_component, license_name)
    @detected_component = detected_component
    @license_name = license_name
    mail(to: ALICE['spy_mail_list'], subject: "Cancellazione di un componente rilevato")
  end  
  def component_email(component, license_name)
    @component = component
    @license_name = license_name
    mail(to: ALICE['spy_mail_list'], subject: "Modifica ad un componente in archivio")
  end  
  def component_destroyed_email(component, license_name)
    @component = component
    @license_name = license_name
    mail(to: ALICE['spy_mail_list'], subject: "Cancellazione di un componente in archivio")
  end  
  def license_email(license, similar_license_description, license_type_description)
    @license = license
    @similar_license_description = similar_license_description
    @license_type_description = license_type_description
    mail(to: ALICE['spy_mail_list'], subject: "Modifica ad una licenza")
  end  
  def license_destroyed_email(license)
    @license = license
    mail(to: ALICE['spy_mail_list'], subject: "Cancellazione di una licenza")
  end  
  def license_created_email(license, similar_license_description, license_type_description)
    @license = license
    @similar_license_description = similar_license_description
    @license_type_description = license_type_description
    mail(to: ALICE['spy_mail_list'], subject: "Inserimento di una nuova licenza")
  end  
  def relation_destroyed_email(product_name, version_name, component, component_license, user)
    @product_name = product_name
    @version_name = version_name
    @component = component
    @component_license = component_license
    @user = user
    mail(to: ALICE['spy_mail_list'], subject: "Cancellazione componente di una release")
  end  
  def release_email(release, license_name)
    @release = release
    @license_name = license_name
    mail(to: ALICE['spy_mail_list'], subject: "Modifica di una release")
  end  
end
