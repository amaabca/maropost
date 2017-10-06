module Helpers
  module Requests
    @@default_json_response = File.read File.join('spec', 'fixtures', 'contacts', 'contact.json')

    def stub_find_maropost_contact(opts = {})
      email = opts.fetch(:email)
      body = opts.fetch(:body, @@default_json_response)
      status = opts.fetch(:status, 200)
      stub_request(:get, /.*contacts\/email\.json\?contact\[email\]=#{email}*/).to_return(status: status, body: body, headers: {})
    end

    def stub_create_maropost_contact(opts = {})
      body = opts.fetch(:body, @@default_json_response)
      status = opts.fetch(:status, 200)
      stub_request(:post, /.*contacts\.json/).to_return(status: status, body: body, headers: {})
    end

    def stub_update_maropost_contact(opts = {})
      contact_id = opts.fetch(:contact_id)
      body = opts.fetch(:body, @@default_json_response)
      status = opts.fetch(:status, 200)
      stub_request(:put, /.*contacts\/#{contact_id}\.json*/).to_return(status: status, body: body, headers: {})
    end

    def stub_do_not_mail_list_exists(opts = {})
      status = opts.fetch(:status, 200)
      body = opts.fetch(:body, '')
      stub_request(:get, /.*global_unsubscribes\/email.json/).to_return(body: body, status: status)
    end

    def stub_do_not_mail_list_create(opts = {})
      status = opts.fetch(:status, 200)
      stub_request(:post, /.*global_unsubscribes/).to_return(status: status)
    end

    def stub_do_not_mail_list_delete(opts = {})
      status = opts.fetch(:status, 200)
      stub_request(:delete, /.*global_unsubscribes\/delete/).to_return(status: status)
    end
  end
end
