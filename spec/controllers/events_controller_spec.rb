require 'rails_helper'

RSpec.describe EventsController, type: :controller do

  describe "POST Events create" do
    context "With valid attributes" do
      before :each do
        # reset all_events
        @request.env["CONTENT_TYPE"] = "application/octet-stream"
        $all_events = []
      end

      it "Create a new event" do
        appsha = rand_sha256
        sample_ip = rand_good_ip.to_i
        ip_event = Definitions::IpEvent.encode(Definitions::IpEvent.new(app_sha256: appsha, ip: sample_ip))
        post :create, body: ip_event
        expect(response.status).to eq(200)
        expect($all_events.length).to eq(1)
        expect($all_events[0][:app_sha]).to eq(appsha)
        expect($all_events[0][:ips]).to eq([sample_ip])
      end
    end

    context "With invalid attributes" do
      before :each do
        # reset all_events
        @request.env["CONTENT_TYPE"] = "application/octet-stream"
        $all_events = []
      end

      it "Should throw ParseError for non binary string" do
        post :create, body: "testing"
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)["errors"][0].include?("ParseError:")).to eq(true)
        expect($all_events.length).to eq(0)
      end

      it "Should throw ArgumentError for params as integer" do
        post :create, body: 12344
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)["errors"][0].include?("ArgumentError:")).to eq(true)
        expect($all_events.length).to eq(0)
      end

      it "Should throw an error for empty params" do
        ip_event = Definitions::IpEvent.encode(Definitions::IpEvent.new)
        post :create, body: ip_event
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)["errors"][0]).to eq("sha and IP both params are required")
        expect($all_events.length).to eq(0)
      end
    end
  end

  describe "Get Events" do
    let!(:uniq_good_ips) { good_ips }
    let!(:uniq_bad_ips) { bad_ips }
    let!(:app_sha256) { rand_sha256 }
    let!(:all_ips) { (uniq_good_ips + uniq_bad_ips).map{|ip| ip.to_i}  }
    context "With valid attributes" do

      it "return all good and bad ips" do
        prepare_events
        get :show, params: {id: $all_events[0][:app_sha]}
        expect(JSON.parse(response.body)["count"]).to eq(all_ips.length)
        expect(JSON.parse(response.body)["good_ips"]).to eq(convert_to_ip(uniq_good_ips))
        expect(JSON.parse(response.body)["bad_ips"]).to eq(convert_to_ip(uniq_bad_ips))
      end
    end

    context "With Invalid attributes" do
      it "should throw an error message, Invalid sha256" do
        prepare_events
        sha256 = rand_sha256
        get :show, params: {id: sha256}
        expect(JSON.parse(response.body)["errors"]).to eq("Invaild app_sha256")
      end
    end
  end

  describe "Delete Events" do
    context "Delete all events" do
      it "all_events variables should be empty" do
        $all_events = []
        $all_events << {app_sha: rand_sha256, ips: [good_ips]}
        delete :destroy
        expect($all_events.length).to eq(0)
      end
    end
  end

end
