class Api::V1::Accounts::MiletoBotController < Api::V1::Accounts::BaseController
  before_action :check_authorization

  def status
    response = make_api_request('GET', '/status')
    render json: response, status: :ok
  rescue StandardError => e
    Rails.logger.error("Mileto Bot API Error: #{e.message}")
    render json: { error: 'Failed to fetch bot status' }, status: :service_unavailable
  end

  def toggle
    response = make_api_request('PUT', '/toggle', { enabled: params[:enabled] })
    render json: response, status: :ok
  rescue StandardError => e
    Rails.logger.error("Mileto Bot API Error: #{e.message}")
    render json: { error: 'Failed to update bot status' }, status: :service_unavailable
  end

  private

  def check_authorization
    raise Pundit::NotAuthorizedError unless Current.account_user.administrator?
  end

  def make_api_request(method, path, body = nil)
    uri = URI("https://api.mileto.ai/chatwoot-events/bot#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = case method
              when 'GET'
                Net::HTTP::Get.new(uri)
              when 'PUT'
                Net::HTTP::Put.new(uri)
              when 'POST'
                Net::HTTP::Post.new(uri)
              end

    request['x-api-key'] = ENV.fetch('MILETO_API_KEY', '')
    request['Content-Type'] = 'application/json' if body

    request.body = body.to_json if body

    response = http.request(request)
    JSON.parse(response.body)
  end
end
