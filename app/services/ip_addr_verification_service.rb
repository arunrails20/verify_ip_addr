# frozen_string_literal: true

# Determine the good and bad ips
class IPAddrVerificationService
  attr_accessor :app_sha256, :good_ips, :bad_ips

  def initialize(app_sha256)
    @app_sha256 = app_sha256
    @good_ips = []
    @bad_ips = []
  end

  def process
    all_ips.present? ? prepare_results : {}
  end

  def prepare_results
    split_good_ips
    @bad_ips = unique_ips - good_ips
    { count: all_ips.count,
      good_ips: convert_to_ip(good_ips),
      bad_ips: convert_to_ip(bad_ips) }
  end

  private

  def all_ips
    @all_ips ||= $all_events.find do |sha|
      sha[:app_sha] == app_sha256
    end.try(:[], :ips)
  end

  def unique_ips
    @unique_ips ||= all_ips.uniq
  end

  def split_good_ips
    unique_ips_sort = unique_ips.sort
    unique_ips_sort.each_with_index do |val, i|
      if val + 1 == unique_ips_sort[i + 1] || val == unique_ips_sort[i - 1] + 1
        good_ips << val
      end
    end
  end

  def convert_to_ip(values)
    values.map { |s| [s.to_i].pack('N').unpack('CCCC').join('.') }
  end
end
