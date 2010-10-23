#!/usr/bin/env ruby
require 'config/environment'
require 'db_state'

include DBState
load(ARGV[0])
