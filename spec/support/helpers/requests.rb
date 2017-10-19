# frozen_string_literal: true

module Helpers
  module Requests
    def stub_find_maropost_contact(opts = {})
      email = opts.fetch(:email)
      body = opts.fetch(:body) { default_json_response }
      status = opts.fetch(:status, 200)
      url = maropost_url(
        'contacts/email.json',
        'contact[email]': email,
        'auth_token': Maropost.configuration.auth_token
      )
      stub_request(:get, url)
        .to_return(
          status: status,
          body: body
        )
    end

    def stub_create_maropost_contact(opts = {})
      body = opts.fetch(:body) { default_json_response }
      status = opts.fetch(:status, 200)
      stub_request(:post, maropost_url('contacts.json'))
        .to_return(
          status: status,
          body: body
        )
    end

    def stub_update_maropost_contact(opts = {})
      contact_id = opts.fetch(:contact_id)
      body = opts.fetch(:body) { default_json_response }
      status = opts.fetch(:status, 200)
      stub_request(:put, maropost_url("contacts/#{contact_id}.json"))
        .to_return(
          status: status,
          body: body
        )
    end

    def stub_do_not_mail_list_exists(opts = {})
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body) { '' }
      email = opts.fetch(:email) { 'test+001@test.com' }
      url = maropost_url(
        'global_unsubscribes/email.json',
        'contact[email]': email,
        'auth_token': Maropost.configuration.auth_token
      )
      stub_request(:get, url)
        .to_return(
          body: body,
          status: status
        )
    end

    def stub_do_not_mail_list_create(opts = {})
      status = opts.fetch(:status, 200)
      stub_request(:post, maropost_url('global_unsubscribes.json'))
        .to_return(
          status: status
        )
    end

    def stub_do_not_mail_list_delete(opts = {})
      status = opts.fetch(:status, 204)
      email = opts.fetch(:email) { 'test+001@test.com' }
      url = maropost_url(
        'global_unsubscribes/delete.json',
        'email': email
      )
      stub_request(:delete, url)
        .to_return(
          status: status
        )
    end

    private

    def encode_query(hash)
      RestClient::Utils.encode_query_string(hash)
    end

    def maropost_url(path, query = nil)
      query &&= encode_query(query)
      uri = URI.join(Maropost.configuration.api_url, path)
      uri.tap { |u| query && u.query = query }.to_s
    end

    def default_json_response
      read_fixture('contacts', 'contact.json')
    end
  end
end
