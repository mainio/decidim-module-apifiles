# frozen_string_literal: true

# Ruby example for authenticating with the API and uploading a file through the
# `/api/blobs` endpoint.
#
# This example performs the following steps:
# 1. Authenticates the user through `/api/sign_in` using the provided
#    credentials (below).
# 2. Uploads the example file to the `/api/blobs` endpoint through a multipart
#    HTTP POST request.
# 3. Signs out the user using the `/api/sign_out` endpoint through an HTTP
#    DELETE request.
#
# Note that this example uses the `multipart-post` gem as a dependency because
# `net/http` does not currently support multipart requests out of the box.

require "uri"
require "json"
require "net/http"
require "net/http/post/multipart"

host = "http://localhost:3000"
uri = URI.parse(host)

credentials = { email: "admin@example.org", password: "decidim123456789" }

Net::HTTP.start(uri.hostname, uri.port) do |http|
  auth_request = Net::HTTP::Post.new("/api/sign_in")
  auth_request.set_form_data(
    "user[email]" => credentials[:email],
    "user[password]" => credentials[:password]
  )
  auth_response = http.request(auth_request)
  puts "Auth response code: #{auth_response.code}"
  raise "Invalid credentials provided!" unless auth_response.code == "200"

  auth_header = auth_response["Authorization"]
  puts "Auth header: #{auth_header}"

  File.open(File.join(__dir__, "city.jpeg")) do |file|
    request = Net::HTTP::Post::Multipart.new(
      "/api/blobs",
      "file" => UploadIO.new(file, "image/jpeg", "image.jpg")
    )
    request["Authorization"] = auth_header

    response = http.request(request)
    puts "Upload response code: #{response.code}"
    if response.code != "200"
      if response.code == "422"
        details = JSON.parse(response.body)
        pp details
      end

      raise "Upload failed!"
    end

    blob_details = JSON.parse(response.body)
    puts "Blob details:"
    pp blob_details
  end

  signout_request = Net::HTTP::Delete.new("/api/sign_out")
  signout_request["Authorization"] = auth_header
  signout_response = http.request(signout_request)
  puts "Signout response code: #{signout_response.code}"
  raise "Sign out failed!" unless signout_response.code == "200"
end
