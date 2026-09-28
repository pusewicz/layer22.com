# frozen_string_literal: true

require "puma"
require "puma/server"
require "zlib"
require "test_helper"

module Layer22
  # Shared support for the tests of Layer22::Notes.
  module NotesTest
    # A Puma server on a loopback port chosen by the OS, answering with the
    # responses a test registers. The port is bound before +start+ returns, so
    # clients can connect without waiting for the server thread to be scheduled.
    class LocalServer
      Request = Data.define(:path, :query, :headers)

      # @return [Array<Request>] the requests received so far, oldest first
      attr_reader :requests

      def initialize
        @routes = {}
        @requests = []
        @mutex = Mutex.new
      end

      # Binds a loopback port and starts serving on a background thread.
      #
      # @return [LocalServer] self
      def start
        @server = Puma::Server.new(method(:call), Puma::Events.new, log_writer: Puma::LogWriter.null, min_threads: 1, max_threads: 4)
        @server.add_tcp_listener("127.0.0.1", 0)
        @port = @server.connected_ports.fetch(0)
        @server.run
        self
      end

      # Stops the server and waits for its thread to finish.
      def stop
        @server&.stop(true)
        @server = nil
      end

      # @param path [String] a path, optionally with a query
      # @return [String] the absolute URL of +path+ on this server
      def url(path = "/")
        "http://127.0.0.1:#{@port}#{path}"
      end

      # Registers a static response for +path+.
      #
      # @param path [String]
      # @param body [String]
      # @param type [String, nil] content type; none is sent when nil
      # @param status [Integer]
      # @param headers [Hash{String => String}] extra response headers
      def serve(path, body = "", type: "text/html; charset=utf-8", status: 200, headers: {})
        respond(path) do
          [status, type ? {"content-type" => type}.merge(headers) : headers, [body]]
        end
      end

      # Registers a redirect from +path+ to +location+, which may be relative.
      def redirect(path, location, status: 302)
        serve(path, "", type: nil, status:, headers: {"location" => location})
      end

      # Registers +block+ to answer requests for +path+ with a Rack response.
      # The block receives the Rack env.
      def respond(path, &block)
        @mutex.synchronize { @routes[path] = block }
      end

      # @param path [String]
      # @return [Array<Request>] the requests received for +path+
      def requests_for(path)
        @mutex.synchronize { @requests.select { |request| request.path == path } }
      end

      # Rack entry point; unregistered paths are a 404.
      def call(env)
        path = env.fetch("PATH_INFO")
        headers = env.select { |key, _| key.start_with?("HTTP_") }.transform_keys { |key| key.delete_prefix("HTTP_").downcase }
        handler = @mutex.synchronize do
          @requests << Request.new(path:, query: env["QUERY_STRING"], headers:)
          @routes[path]
        end
        handler ? handler.call(env) : [404, {"content-type" => "text/plain"}, ["Not Found"]]
      end
    end

    # Base class for the Notes tests.
    class TestCase < Layer22::TestCase
      # A valid PNG of a solid black image.
      #
      # @return [String] binary data
      def png(width = 4, height = 2)
        chunk = ->(type, data) { [data.bytesize].pack("N") + type + data + [Zlib.crc32(type + data)].pack("N") }
        pixels = ("\0".b + "\0\0\0".b * width) * height
        "\x89PNG\r\n\x1a\n".b +
          chunk.call("IHDR".b, [width, height, 8, 2, 0, 0, 0].pack("NNCCCCC")) +
          chunk.call("IDAT".b, Zlib::Deflate.deflate(pixels)) +
          chunk.call("IEND".b, "".b)
      end

      # Runs the block with every connection attempt refused.
      def with_refused_connections(&)
        Net::HTTP.stub(:start, ->(*, **) { raise Errno::ECONNREFUSED, "connect(2) for \"127.0.0.1\" port 9" }, &)
      end
    end

    # Base class for tests that fetch from a LocalServer, which serves for the
    # length of each test.
    class ServerTestCase < TestCase
      def setup
        super
        @server = LocalServer.new.start
      end

      def teardown
        @server&.stop
        super
      end
    end
  end
end
