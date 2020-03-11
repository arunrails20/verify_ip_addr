# frozen_string_literal: true

require 'rails_helper'
describe IPAddrVerificationService do
  describe '.process' do
    let!(:uniq_good_ips) { good_ips }
    let!(:uniq_bad_ips) { bad_ips }
    let!(:app_sha256) { rand_sha256 }
    let!(:other_sha256) { rand_sha256 }
    let!(:all_ips) { (uniq_good_ips + uniq_bad_ips).map(&:to_i) }
    let!(:service) { IPAddrVerificationService.new(app_sha256) }
    let!(:other_service) { IPAddrVerificationService.new(other_sha256) }
    context 'with valid sha256' do
      it 'Should split good and bad ips' do
        prepare_events
        service.process
        expect(service.good_ips).to eq(uniq_good_ips)
        expect(service.bad_ips).to eq(uniq_bad_ips)
      end
    end
    context 'with invalid sha256' do
      it 'there is no good and bad ips' do
        prepare_events
        other_service.process
        expect(other_service.good_ips.empty?).to eq(true)
        expect(other_service.bad_ips.empty?).to eq(true)
      end
    end
  end
end
