# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(__dir__, "..", "lib"))
require "layer22"

desc "Start development server with Tailwind watch"
task :dev do
  logger = Layer22.logger

  # Start Tailwind in watch mode as a background process
  tailwind_pid = spawn("bunx tailwindcss -i styles/tailwind.input.css -o tmp/tailwind.css --watch",
                       out: "/dev/null", err: "/dev/null")
  logger.info("Tailwind watcher started (PID #{tailwind_pid})")

  # Give tailwind a moment to compile initial CSS
  sleep 1

  at_exit do
    Process.kill("TERM", tailwind_pid) rescue nil
    logger.info("Tailwind watcher stopped")
  end

  require "rackup"
  require "layer22/dev_server"

  app = Layer22::DevServer.build
  server = Rackup::Handler.get("puma")
  logger.info("Dev server starting at http://localhost:4000")
  server.run(app, Port: 4000, Host: "127.0.0.1", Silent: true)
end
