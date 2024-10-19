# frozen_string_literal: true

require 'roda'
require 'slim'

module LeafAPI
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :common_logger, $stderr
    plugin :halt

    route do |routing|
      routing.assets # load CSS
      response['Content-Type'] = 'text/html; charset=utf-8'

      # GET /
      routing.root do
        view 'home'
      end

      # Manage Location resources
      routing.on 'locations' do
        routing.is do
          routing.get do
            view 'location'
          end
        end
      end

      # Manage Trip resources
      routing.on 'trips' do
        routing.get do
          view 'trip'
        end
      end
    end
  end
end
