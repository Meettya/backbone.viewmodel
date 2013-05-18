###
This is Backbone.ViewModel implementation with attributes mapping and synchronization on demand.
###

# we are need Backbone to extend from it
Backbone  = require 'backbone'
_         = require 'lodash'

module.exports = class Backbone.ViewModel extends Backbone.Model

  constructor: (@model, constructor_attrs={}, @options) ->
    throw Error "model required" unless @model
    # call to parent, but empty object will be used
    super constructor_attrs

    # oh! its little smart thingy for synchronization :)
    @_mapping_dictionary_ = @_buildMappingDictionary() || {}

    @_synchronizeWithModel()

  ###
  Public API for synchronization VM with Model
  ###
  reflect : => @_synchronizeWithModel()    

  ###
  This method will synchronize ViewModel data with Model data
  ###
  _synchronizeWithModel : ->
    for self_attr, data_source_fn of @_mapping_dictionary_
      @set self_attr, _.cloneDeep data_source_fn()

  ###
  This method build mapping dictionary with pre-fired function
  ###
  _buildMappingDictionary : ->
    return unless @mapping?

    res_obj = {}
    for self_attr, data_source of @mapping
      do (self_attr, data_source) =>
        # data_source may be string - plain property OR viewmodel function name
        # I dislike function as string name calling, but for BB consistency - it ok
        # function name go first before plain property
        res_obj[self_attr] = if @[data_source]? and _.isFunction @[data_source]
          => @[data_source]()
        else if @model.has data_source
          => @model.get data_source
        else 
          throw Error "can`t map |#{self_attr}| to |#{data_source}| - no self function neither model property"
      
      null

    res_obj





