###
This is common package config
used in server and in build comand
###

path = require 'path'
root_path = path.join  __dirname, '..'

get_pack_config = (filename) ->

  switch filename
    when 'backbone.viewmodel'
      bundle : 
        'Backbone.Viewmodel' : path.join root_path, 'src', filename
      replacement :
        backbone  : path.join root_path, 'web_modules', 'backbone'
        lodash    : path.join root_path, 'web_modules', 'lodash'
    else
      throw Error "dont know |#{filename}| settings"

module.exports = {
  get_pack_config
}