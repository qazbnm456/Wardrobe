Dir[File.expand_path('../../../lib/status_page/*.rb', __FILE__)].each { |file| require file }

StatusPage.configure do
  # Cache check status result 10 seconds
  self.interval = 10
  # Use service
  self.use :database
  self.use :cache
  self.add_custom_service Docker
end
