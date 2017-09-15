require 'spec_helper'

describe Maropost::Contact do
  let(:email) { 'test.teddy@example.com' }

  describe "#find" do
    let(:subject) { Maropost::Contact }

    before(:each) do
      stub_request(:get, "#{Maropost.configuration.api_url}/contacts/email.json?contact[email]=#{email}").to_return(
        status: status,
        body: body
      )
    end

    context "valid search" do
      let(:body) { File.read File.join("spec", "fixtures", "contacts", "get_response.json") }
      let(:status) { 200 }

      it "returns the contact record" do
        result = subject.find(email)
        expect(result).to be_a Maropost::Contact
        expect(result.email).to eq email
        expect(result.errors).to_not be_present
      end
    end

    context "no results" do
      let(:body) { "{}" }
      let(:status) { 404 }

      it "returns a contact record with errors" do
        result = subject.find(email)
        expect(result).to be_a Maropost::Contact
        expect(result.email).to eq email
        expect(result.errors[:base].first).to eq "Email not found"
      end
    end
  end

  describe "#create_or_update" do
    let(:subject) { Maropost::Contact.new(data) }
    let(:opt_in) { "1" }
    let(:business_name) { "Macrocorp" }
    let(:data) {
      {
        id: 741000000,
        email: email,
        travel_especials: opt_in,
        vr_reminder_autocall: opt_in,
        business_vehicle_reminder: business_name
      }
    }

    before(:each) do
      stub_request(:get, "#{Maropost.configuration.api_url}/contacts/email.json?contact[email]=#{email}").to_return(
        status: get_status,
        body: get_body
      )
    end

    context "creating a new record" do
      let(:get_body) { "{}" }
      let(:get_status) { 404 }

      before(:each) do
        stub_request(:post, "#{Maropost.configuration.api_url}/contacts.json").to_return(
          status: status,
          body: body
        )
      end

      context "success" do
        let(:body) { File.read File.join("spec", "fixtures", "contacts", "create_response.json") }
        let(:status) { 201 }

        it "returns the contact record" do
          result = subject.create_or_update
          expect(result).to be_a Maropost::Contact
          expect(result.email).to eq email
          expect(result.travel_especials).to eq opt_in
          expect(result.vr_reminder_autocall).to eq opt_in
          expect(result.business_vehicle_reminder).to eq business_name
          expect(result.errors).to_not be_present
        end
      end

      context "error" do
        let(:body) { "{}" }
        let(:status) { 422 }

        it "returns a contact record with errors" do
          result = subject.create_or_update
          expect(result).to be_a Maropost::Contact
          expect(result.email).to eq email
          expect(result.errors[:base].first).to eq "Unable to create or update contact"
        end
      end
    end

    context "updating an existing record" do
      let(:get_body) { File.read File.join("spec", "fixtures", "contacts", "get_response.json") }
      let(:get_status) { 200 }
      let(:id) { 741000000 }

      before(:each) do
        stub_request(:put, "#{Maropost.configuration.api_url}/contacts/#{id}.json").to_return(
          status: status,
          body: body
        )
      end

      context "success" do
        let(:body) { File.read File.join("spec", "fixtures", "contacts", "create_response.json") }
        let(:status) { 201 }

        it "returns the contact record" do
          result = subject.create_or_update
          expect(result).to be_a Maropost::Contact
          expect(result.email).to eq email
          expect(result.travel_especials).to eq opt_in
          expect(result.vr_reminder_autocall).to eq opt_in
          expect(result.business_vehicle_reminder).to eq business_name
          expect(result.errors).to_not be_present
        end
      end

      context "error" do
        let(:body) { "{}" }
        let(:status) { 422 }

        it "returns a contact record with errors" do
          result = subject.create_or_update
          expect(result).to be_a Maropost::Contact
          expect(result.email).to eq email
          expect(result.errors[:base].first).to eq "Unable to create or update contact"
        end
      end
    end
  end

  describe "#update_email" do
    let(:subject) { Maropost::Contact.new(data) }
    let(:id) { 741000000 }
    let(:new_email) { "wafflezone@example.com" }
    let(:data) {
      {
        email: new_email,
        id: id
      }
    }

    before(:each) do
      stub_request(:put, "#{Maropost.configuration.api_url}/contacts/#{id}.json").to_return(
        status: status,
        body: body
      )
    end

    context "success" do
      let(:body) { File.read File.join("spec", "fixtures", "contacts", "update_email_response.json") }
      let(:status) { 201 }

      it "returns the contact record" do
        result = subject.update_email(new_email)
        expect(result).to be_a Maropost::Contact
        expect(result.email).to eq new_email
        expect(result.errors).to_not be_present
      end
    end

    context "error" do
      let(:body) { "{}" }
      let(:status) { 422 }

      it "returns a contact record with errors" do
        result = subject.update_email(new_email)
        expect(result).to be_a Maropost::Contact
        expect(result.email).to eq new_email
        expect(result.errors[:base].first).to eq "Unable to update email to #{new_email}"
      end
    end
  end
end
