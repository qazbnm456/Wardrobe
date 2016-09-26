require 'rancher/api/helpers/model'
module Rancher
  module Api
    # Rancher Api still not support to list images on host (https://github.com/rancher/rancher/issues/1277)
    <<~'Rancher::Api::Image'
    module Helpers
      module Model
        extend ActiveSupport::Concern
        included do |mod|
          if "#{mod}" == "Rancher::Api::Host"
            has_many :images
          end
        end
      end
    end

    class Image
      include Her::Model
      include Helpers::Model

      belongs_to :host
    end
    Rancher::Api::Image

    module Helpers
      module Model
        extend ActiveSupport::Concern
        included do |mod|
          if "#{mod}" == "Rancher::Api::Project"
            has_many :stacks
          elsif "#{mod}" == "Rancher::Api::Service"
            collection_path "projects/:accountId/services"

            belongs_to :stack
          end
        end
      end
    end
  end
end

# We have to setup Her before include Her::Model
Rancher::Api.configure do |config|
  config.url = ENV['RANCHER_URL']
  config.access_key = ENV['RANCHER_ACCESS_KEY']
  config.secret_key = ENV['RANCHER_SECRET_KEY']
  config.verbose = true if Rails.env.development?
end

module Rancher
  module Api
    class Stack
      include Her::Model
      include Helpers::Model

      collection_path "projects/:accountId/stacks"

      belongs_to :project
      has_many :services

      def create_service_with_name(name, image, tag, stackId, accountId)
        container = {
            'capAdd' => [
            ],
            'capDrop' => [
            ],
            'cpuSet' => "1",
            'cpuShares' => 256,
            'dataVolumeMounts' => nil,
            'dataVolumes' => [
            ],
            'dataVolumesFrom' => [
            ],
            'devices' => [
            ],
            'dns' => [
            ],
            'dnsSearch' => [
            ],
            'domainName' => nil,
            'hostname' => nil,
            'imageUuid' => "docker:#{image}:#{tag}",
            'kind' => "container",
            'logConfig' => {
                'config' => {
                },
                'driver' => ""
            },
            'memory' => 300000000,
            'memorySwap' => nil,
            'networkLaunchConfig' => nil,
            'networkMode' => "managed",
            'pidMode' => nil,
            'ports' => [
            ],
            'privileged' => false,
            'publishAllPorts' => false,
            'readOnly' => false,
            'startOnCreate' => false,
            'stdinOpen' => false,
            'tty' => true,
            'user' => nil,
            'userdata' => nil,
            'version' => "0",
            'vcpu' => 1,
            'volumeDriver' => nil,
            'workingDir' => nil
        }

        data = {
            "assignServiceIpAddress": false,
            "description": nil,
            "launchConfig": container,
            "name": "#{name}",
            "scale": 1,
            "secondaryLaunchConfigs": [],
            "selectorContainer": nil,
            "selectorLink": nil,
            "stackId": "#{stackId}",
            "startOnCreate": false,
            "vip": nil,
            # Additional Param
            "accountId": "#{accountId}"
        }

        action = self.services.create(data)
      end
    end

    class Service
      class Action
        include Her::Model
      end

      def activate
        url = actions['activate']

        action = Action.post(url)
      end

      def deactivate
        url = actions['deactivate']

        action = Action.post(url)
      end

      def remove
        url = actions['remove']

        action = Action.post(url)
      end
    end

    class Instance
      def terminal(command)
        url = actions['execute']

        data = {
            'attachStdin' => true,
            'attachStdout' => true,
            'command' => command,
            'tty' => true
        }

        Action.post(url, data)
      end
    end
  end
end
