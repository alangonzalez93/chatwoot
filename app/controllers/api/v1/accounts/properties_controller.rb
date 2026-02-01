class Api::V1::Accounts::PropertiesController < Api::V1::Accounts::BaseController
  before_action :check_authorization

  def index
    page = params[:page]&.to_i || 0
    size = params[:size]&.to_i || 20

    response = make_api_request('GET', "/details?page=#{page}&size=#{size}")
    render json: response, status: :ok
  rescue StandardError => e
    Rails.logger.error("Properties API Error: #{e.message}")
    render json: { error: 'Failed to fetch properties' }, status: :service_unavailable
  end

  def show
    property_id = params[:id]
    response = make_api_request('GET', "/details/#{property_id}")
    render json: response, status: :ok
  rescue StandardError => e
    Rails.logger.error("Property Detail API Error: #{e.message}")
    render json: { error: 'Failed to fetch property details' }, status: :service_unavailable
  end

  private

  def check_authorization
    raise Pundit::NotAuthorizedError unless Current.account_user.administrator?
  end

  def make_api_request(method, path)
    api_key = ENV['MILETO_API_KEY']
    raise 'MILETO_API_KEY environment variable is not configured' if api_key.blank?

    uri = URI("https://api.mileto.ai/api/properties#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    request['X-API-Key'] = api_key
    request['Content-Type'] = 'application/json'

    response = http.request(request)
    JSON.parse(response.body)
  end
end
