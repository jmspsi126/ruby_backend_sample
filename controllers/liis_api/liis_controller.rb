module LiisApi
  class LiisController < ApplicationController
    include ApipieDescriptions::LiisFaults
    skip_before_filter :verify_authenticity_token

    http_basic_authenticate_with(
      name: "username",
      password: "blop7nub3pok2dan"
    )
  end
end
