# frozen_string_literal: true

# Handle all events requests
class EventsController < ApplicationController
  before_action :restrict_content_type, only: :create

  def create
    # Store all the Events in $all_events Global variable
    event = EventCreationService.new(request.raw_post)
    if event.process
      render json: {}, status: :ok
    else
      render json: { errors: event.errors }, status: :ok
    end
  end

  def destroy
    $all_events.clear
  end

  def show
    results = IPAddrVerificationService.new(params[:id]).process
    if results.present?
      render json: results
    else
      render json: { errors: 'Invaild app_sha256' }, status: :ok
    end
  end

  private

  # For create action, allow only application/octet-stream content type.
  def restrict_content_type
    return if request.content_type == 'application/octet-stream'

    render json: { msg: "Content-Type must be application/octet-stream" }, status: 406
  end
end
