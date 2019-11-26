#!/bin/sh
set -e

# Puppet Task Name: get_service_status
#
# This task gets the status of the LiDAR docker-compose services.
#
cd /opt/puppetlabs/lidar
docker-compose ps
