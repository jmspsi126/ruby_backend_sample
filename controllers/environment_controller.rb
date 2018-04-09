class EnvironmentController < ApplicationController
  def show
    render(
      json: {
        env: Rails.env,
        url_options: default_url_options
      }
    )
  end
end
