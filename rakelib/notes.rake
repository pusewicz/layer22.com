# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(__dir__, "..", "lib"))
require "layer22"

desc "Create a note from the clipboard, or from stdin when piped"
task :note do
  text = $stdin.tty? ? IO.popen(["pbpaste"], &:read) : $stdin.read
  puts "Created #{Layer22::Notes.create(text)}"
rescue Layer22::Notes::Error, Errno::ENOENT => e
  abort e.message
end
