CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage :fog
    config.fog_directory  = ENV['AWS_BUCKET']
    config.fog_public = false
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION'],
    }
  elsif Rails.env.test?
    CarrierWave.configure do |config|
      config.storage = :file
      config.enable_processing = true
      config.root = Rails.root.join('public/uploads/test')
    end
  else
    config.storage :file
    config.enable_processing = false if Rails.env.test?
  end
end
