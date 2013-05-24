[![Build Status](https://secure.travis-ci.org/Meettya/backbone.viewmodel.png)](http://travis-ci.org/Meettya/backbone.viewmodel)  [![Dependency Status](https://gemnasium.com/Meettya/backbone.viewmodel.png)](https://gemnasium.com/Meettya/backbone.viewmodel)

# Backbone.ViewModel

Yes, YA Backbone.ViewModel here! Because we are can! :)

Actually I need solutions to link two different Views on base of one Model and ViewModel is matter. See example project for more details.

## Description:

**Backbone.ViewModel** may used between Model and View in Backbone or BB.Marionette or other BB-compatibility projects.

Its not drop-in replacement for Model, but it handle correctly some methods and properties form Model and should play well with others (you may write request with testcase if important Madel functionality looks omitted).

As ViewModel its support some additional features as computed values, controlled autosync with Model and defaults values.

## Install:

### node.js

    npm install backbone.viewmodel

### browser

Get copy of `/browser_lib/backbone.viewmodel.js` or use CommonJS-style with [clinch](https://github.com/Meettya/clinch).

## Usage:

All examples written with CoffeeScript, you may use plain JS instead (but why?).

How its works:

    class RectangleViewModel extends Backbone.ViewModel
      autoupdate  : on
      mapping : 
        color   : 'color'
        width   : 'size'
        height  : 'getHeight'
      getHeight : ->
        @model.get('size') * ( 1 + Math.random() ) | 0

    rectangle = new RectangleViewModel color : 'blue', size : 20
    console.log rectangle.toJSON() # -> Object {color: "blue", width: 20, height: 22} 

    rectangle.model.set 'size', 50 # its bad example of `model` interaction, but ok here
    console.log rectangle.toJSON() # -> Object {color: "blue", width: 50, height: 74} 

## API

**Backbone.ViewModel** have few methods and some numbers of class properties.

### Properties:

    ###
    model prop may be used to create specific Model from raw data,
    by default VM use Backbone.Model
    ###
    model       : BaseBB.Model
    ###
    VM do not auto-update itself properties on model changes
    use this knob to turn it on
    ###
    autoupdate  : on
    ###
    all keys in mapping will be 'mapped' self VM functions OR
    model attributes, with priority: function, than attributes
    ###
    mapping : 
      color   : 'color'
      height  : 'getHeight'

### Methods:

#### constructor(dataIn, constructorAttrs, options)

 - `dataIn` - BB.Model or raw data object
 - `constructorAttrs` - default VM properties may be placed here
 - `options` - some options, like `autoupdate`

#### update()

Just proceed process to update VM from current model state. May be called if `autoupdate` property not used for some reason.

### BB.Model methods

**Backbone.ViewModel** as BB.Model will support much helpfully methods like `toJSON()` or `get()`, dozen unsuitably methods like `set()` `unset()` or `clear()` and (at now) will available to call erroneously methods like `fetch()` or `sync()` - just do not use them.

If you need to have synced model  - create it first and use thyself methods in ViewModel `update` or `autoupdate` combinations.


