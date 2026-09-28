# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(__dir__, "..", "lib"))
require "layer22"

desc "Start the development server"
task :dev do
  require "rackup"
  require "layer22/dev_server"

  app = Layer22::DevServer.build
  server = Rackup::Handler.get("puma")
  Layer22.logger.info("Dev server starting at http://localhost:4000")
  server.run(app, Port: 4000, Host: "127.0.0.1", Silent: true)
end
