# Load the Rails application.
require_relative 'application'
require "json"
require "ibm_watson"
require "ibm_watson/authenticators"
require "ibm_watson/natural_language_understanding_v1"
# Initialize the Rails application.
Rails.application.initialize!
