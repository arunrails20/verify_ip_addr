# frozen_string_literal: true

require 'rails_helper'
$all_events = []
describe EventCreationService do
  describe '.process' do
    let!(:good_ip) { rand_good_ip.to_i }
    let!(:app_sha256) { rand_sha256 }
    let!(:params) { Definitions::IpEvent.encode(Definitions::IpEvent.new(app_sha256: app_sha256, ip: good_ip)) }
    let!(:service) { EventCreationService.new(params) }

    context 'with valid attributes' do
      it 'Should return true and empty errors obj' do
        expect(service.process).to eq(true)
        expect(service.errors.empty?).to eq(true)
      end
      it 'decoded event' do
        service.process
        expect(service.parsed_event.app_sha256).to eq(app_sha256)
        expect(service.parsed_event.ip).to eq(good_ip)
      end
    end

    context 'with invalid attributes' do
      it 'Should return False and with errors obj' do
        service = EventCreationService.new(Definitions::IpEvent.encode(Definitions::IpEvent.new))
        expect(service.process).to eq(false)
        expect(service.errors.empty?).to eq(false)
      end
    end
  end
end
