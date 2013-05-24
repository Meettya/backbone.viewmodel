###
This is Backbone.ViewModel implementation with attributes mapping and synchronization on demand.
###

# we are need Backbone to extend from it
Backbone  = require 'backbone'
_         = require 'lodash'

module.exports = class Backbone.ViewModel extends Backbone.Model

  constructor: (data_in, constructor_attrs={}, @_options_={}) ->
    throw Error "model or raw data required, but got |#{data_in}|" unless data_in

    # suppose all our model are BB.Model instances, may be its wrong
    # but I don't known how decide is it whole Model or just raw data
    # futures detection stinks too
    @model =  if data_in instanceof Backbone.Model then data_in \
                else @_createModelFromRawData data_in
    
    super constructor_attrs

    # oh! its little smart thingy for synchronization :)
    @_mapping_dictionary_ = @_buildMappingDictionary() || {}

    # add autoupdate options
    if @_options_.autoupdate || @autoupdate
      @model.on 'change', @update

    @update()

  ###
  Public API for synchronization VM with Model
  ###
  update : => @_synchronizeWithModel()    

  ###
  This method will synchronize ViewModel data with Model data
  NB we are can't to do lazy re-load with @model.changedAttributes
  because keys in _mapping_dictionary_ not one-to-one mapped to model properties
  ###
  _synchronizeWithModel : ->
    for self_attr, data_source_fn of @_mapping_dictionary_
      @set self_attr, _.cloneDeep data_source_fn()

  ###
  This method build mapping dictionary with pre-fired function
  ###
  _buildMappingDictionary : ->
    return null unless @mapping?

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

  ###
  This method will create model if we are got raw data
  ###
  _createModelFromRawData : (raw_data) ->
    constructor = unless @constructor::model?
      Backbone.Model
    else
      @constructor::model

    new constructor raw_data




