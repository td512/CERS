require "cdds/version"

module CERS
  require 'rubygems'
  require 'time'
  require 'rest-client'
  require 'base64'

  class DataError < StandardError; end
  class AuthError < StandardError; end
  API_VERSION="v2"
  def self.search(search_term, registered_only, role_type, page_size)
    registered_only = true if registered_only.blank?
    role_type = "ALL" if role_type.blank?
    page_size = 50 if page_size.blank?
    response = RestClient.get("https://api.business.govt.nz/services/#{API_VERSION}/companies-office/entity-roles/search?name=#{search_term}&page-size=#{page_size}&registered-only=#{registered_only}&role-type=#{role_type}",
                              { authorization: "Bearer #{access_token}", accept: 'application/json' })
    begin
      JSON.parse(response.body).with_indifferent_access
    rescue JSON::ParserError
      raise CERS::DataError, "CERS API returned bad data"
    end
  end

  private

  def self.access_token
    begin
      response = RestClient.post("https://api.business.govt.nz/services/token", { grant_type: "client_credentials" },
                                 { grant_type: "client_credentials", authorization: "Basic #{Base64.strict_encode64(ENV["MBIE_ID"] + ":" + ENV["MBIE_SECRET"])}" })

      JSON.parse(response.body)["access_token"]
    rescue JSON::ParserError, NoMethodError
      raise CERS::AuthError, "Authentication failed! Are you missing MBIE_ID or MBIE_SECRET?"
    end

  end
end
