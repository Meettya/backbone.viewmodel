###
New Cakefile with good organization
###
async = require 'async'
path  = require 'path'
fs    = require 'fs'

root_path = path.dirname fs.realpathSync __filename

paths = 
  cake_dep          : 'cake_dep'
  src_dir           : 'src'
  lib_dir           : 'lib'
  browser_lib_dir   : 'browser_lib'

# extend path with root
for own key, value of paths
   paths[key] = path.join root_path, value
   null

# add commands
commands = require path.join paths.cake_dep, 'command'

task 'build_node', 'build coffee to js for node.js', build_node = (cb) ->
  commands.build_coffee paths.src_dir, paths.lib_dir, cb

task 'build_browser', 'build coffee to js for browser', build_browser = (cb) ->
  commands.compile_src_for_browser  paths.src_dir, paths.browser_lib_dir, cb

task 'build_all', 'build coffee to js for both platforms', build_all = (cb) ->

  async.parallel {
    build_node : (pcb) -> build_node(pcb)
    build_browser : (pcb) -> build_browser(pcb)
    }, (err,res) ->
      return console.log err if err?
      console.log 'task build_all done'