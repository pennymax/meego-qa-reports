#!/usr/bin/env ruby

# Dumps current state from dev environment to named SQL file under features/resources
# Usage: script/dump_state.rb <basename>
#
# Eg. script/dump_state.rb cheezburger # => features/resources/cheezburger_state.sql
require 'config/environment'
require 'db_state'

include DBState
dump(ARGV[0])
