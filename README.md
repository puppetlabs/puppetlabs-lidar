
# lidar

This module will help you setup LiDAR's report processor on a PE Master or Compiler. It will also help you setup a node to host the LiDAR application stack.

- [Description](#description)
- [Setup](#setup)
  - [What lidar affects](#what-lidar-affects)
  - [Setup Requirements](#setup-requirements)
- [Usage](#usage)
- [Reference](#reference)
- [Changelog](#changelog)

## Description

There are two parts to getting started with LiDAR:

1. Setting up a node to run LiDAR itself (`lidar::app_stack`)
2. Configuring your PE Master and any Compilers to send data to LiDAR (`lidar::report_processor`)

## Setup

### What lidar affects

This module will modify the puppet.conf configuration of any master or compiler that it is applied to. Additionally, it will install and configure Docker on the node running LiDAR.

### Setup Requirements

LiDAR only works with Puppet Enterprise.

## Usage

See [REFERENCE.md](REFERENCE.md) for example usage.

## Reference

A custom fact named `lidar` is included as part of this module. It is a structured fact that returns information about the currently running instance of LiDAR.

This module is documented via `pdk bundle exec puppet strings generate --format markdown`. Please see [REFERENCE.md](REFERENCE.md) for more info.

## Changelog

[CHANGELOG.md](CHANGELOG.md) is generated prior to each release via `pdk bundle exec rake changelog`. This process relies on labels that are applied to each pull request.
