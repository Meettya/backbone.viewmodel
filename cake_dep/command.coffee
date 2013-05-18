###
This is command library

to wipe out Cakefile from realization 
###

path          = require 'path'
fs            = require 'fs-extra'
{spawn, exec} = require 'child_process'
Clinch        = require 'clinch'
_             = require 'lodash'


packer = new Clinch

{get_pack_config} = require './pack_configurator'


# add color to console
module.exports = require './colorizer'

###
Just proc extender
###
proc_extender = (cb, proc) =>
  proc.stderr.on 'data', (buffer) -> console.log "#{buffer}".error
  # proc.stdout.on 'data', (buffer) -> console.log  "#{buffer}".info
  proc.on        'exit', (status) ->
    process.exit(1) if status != 0
    cb() if typeof cb is 'function' 
  null

# Run a CoffeeScript through our node/coffee interpreter.
run_coffee = (args, cb) =>
  proc_extender cb, spawn 'node', ['./node_modules/.bin/coffee'].concat args

###
Generate array of files from directory, selected on filter as RegExp
###
make_files_list = (in_dir, filter_re) ->
  for file in fs.readdirSync in_dir when file.match filter_re
    path.join in_dir, file 

###
CoffeeScript-to-JavaScript builder for node.js
###
build_coffee = (source_dir, result_dir, cb) ->
  files = make_files_list source_dir, /\.coffee$/
  run_coffee ['-c', '-o', result_dir].concat(files), ->
    console.log ' -> build done'.info
    cb() if typeof cb is 'function' 
  null

###
CoffeeScript-to-JavaScript builder for browser
###
compile_src_for_browser = (source_dir, result_dir, cb) ->
  files = make_files_list source_dir, /\.coffee$/

  all_done = _.after files.length, cb

  for file in files
    do (file) ->
      filename = path.basename file, '.coffee'

      pack_config = get_pack_config filename

      packer.buldPackage pack_config, (err, data) ->
        throw err if err?
        fs.outputFile "#{path.join result_dir, filename}.js", data, encoding='utf8', (err) ->
          throw err if err?
          console.log "Compiled #{filename}.js"
          all_done()


module.exports = {
  build_coffee
  compile_src_for_browser
}

  


