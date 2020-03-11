# frozen_string_literal: true
# collect all events in $all_events
class EventCreationService
  attr_accessor :params, :errors, :parsed_event

  def initialize(params)
    @params = params
    @errors = []
    @parsed_event = nil
  end

  # Return false incase of validation errors
  # Return true for successfull creation
  def process
    return false unless ready_for_processing?

    if app_sha
      app_sha[:ips] << parsed_event.ip
    else
      $all_events << { app_sha: parsed_event.app_sha256, ips: [parsed_event.ip] }
    end
    true
  end

  private

  def ready_for_processing?
    validate_params
    return false if errors.present?

    data_validations
    errors.empty?
  end

  def validate_params
    @parsed_event = Definitions::IpEvent.decode(params)
  rescue Google::Protobuf::ParseError => e
    errors << 'ParseError: (' + e.message + ')'
  rescue ArgumentError => e
    errors << 'ArgumentError: (' + e.message + ')'
  end

  def data_validations
    app_sha256 = parsed_event.try(:app_sha256)
    ip = parsed_event.try(:ip)
    return if app_sha256.present? && ip.try(:positive?)

    errors << 'sha and IP both params are required'
  end

  def app_sha
    $all_events.find { |sha| sha[:app_sha] == parsed_event.app_sha256 }
  end
end
