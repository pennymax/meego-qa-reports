module DeviseRegistrationConfig
  URL_TOKEN = (Rails.env.production? || Rails.env.staging?) ?
          File.read(File.join(Rails.root, "config", "registeration_token")).strip :
          ""
end