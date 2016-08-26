#
# Cookbook: nrpe-ng
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
require 'poise'

module NrpeNgCookbook
  module Provider
    # A `nrpe_installation` provider which provides package
    # installation of NRPE resource.
    # @provides nrpe_installation
    # @action create
    # @action remove
    # @since 1.0
    class NrpeInstallationPackage < Chef::Provider
      include Poise(inversion: :nrpe_installation)
      provides(:package)
      inversion_attribute('nrpe-ng')

      # @param [Chef::Node] _node
      # @param [Chef::Resource] _resource
      # @api private
      def self.provides_auto?(_node, _resource)
        true
      end

      # Set the default inversion options.
      # @param [Chef::Node] node
      # @param [Chef::Resource] _resource
      # @return [Hash]
      # @api private
      def self.default_inversion_options(node, _resource)
        super.merge(package: default_package_name(node),
                    version: default_package_version(node))
      end

      def action_create
        notifying_block do
          # @see {NrpeNgCookbook::Resource::NrpeService}
          init_file = file '/etc/init.d/nrpe' do
            action :nothing
          end

          dpkg_autostart 'nagios-nrpe-server' do
            action :create
            allow false
            only_if { node.platform_family?('debian') }
          end

          package_path = if options[:url] # ~FC023
                           remote_file ::File.basename(options[:url]) do
                             path ::File.join(Chef::Config[:file_cache_path], name)
                             source options[:url]
                           end.path
                         end

          package_version = options[:version]
          package options[:package] do
            notifies :delete, init_file, :immediately
            provider Chef::Provider::Package::Yum if node.platform_family?('rhel')
            if node.platform_family?('debian')
              options '-o Dpkg::Options::=--path-exclude=/etc/nagios/*'
            end
            version package_version
            source package_path
          end
        end
      end

      def action_remove
        notifying_block do
          package_version = options[:version]
          package options[:package] do
            version package_version
            if node.platform_family?('debian')
              action :purge
            else
              action :remove
            end
          end
        end
      end

      # @param [Chef::Node] node
      # @return [Array]
      # @api private
      def self.default_package_name(node)
        case node['platform']
        when 'centos', 'redhat' then %w{nrpe}
        when 'ubuntu' then %w{nagios-nrpe-server}
        end
      end

      # @param [Chef::Node] node
      # @return [Array]
      # @api private
      def self.default_package_version(node)
        case node['platform']
        when 'redhat', 'centos'
          case node['platform_version'].to_i
          when 5 then %w{2.15-7.el5}
          when 6 then %w{2.15-7.el6}
          when 7 then %w{2.15-7.el7}
          end
        when 'ubuntu'
          case node['platform_version'].to_i
          when 12 then %w{2.12-5ubuntu1}
          when 14 then %w{2.15-0ubuntu1}
          when 16 then %w{2.15-1ubuntu1}
          end
        end
      end

      # @return [String]
      # @api private
      def nagios_plugins
        if node.platform_family?('debian')
          options.fetch(:plugins, '/usr/lib/nagios/plugins')
        else
          options.fetch(:plugins, '/usr/lib64/nagios/plugins')
        end
      end

      # @return [String]
      # @api private
      def nrpe_program
        options.fetch(:program, '/usr/sbin/nrpe')
      end
    end
  end
end
