###
Test for node.js and browser
###

# yap, for tests we are need it
cheerio   = require 'cheerio'
Backbone  = require 'backbone'
_         = require 'lodash'

# fix BB in nodejs check fail
if GLOBAL?
  Backbone.View.prototype._ensureElement = ->

# TODO comment on production
inspect = GLOBAL?.inspect

lib_path = GLOBAL?.lib_path || ''
Backbone.ViewModel = require "#{lib_path}backbone.viewmodel"

describe 'Backbone.ViewModel:', ->

  bbObj = tObj = $ = null

  constructor_options = 
    radius : 40
    width : 0

  bb_model_defaults = 
    color: 'yellow'
    size: 45
    deep : 
      value : false

  bb_view_model_defaults = 
    border : yes
    radius : 10

  class BB_Model_Base extends Backbone.Model
    defaults : 
      bb_model_defaults

    getSize : ->
      @get 'size'

  class BB_View_Model_Base extends Backbone.ViewModel
    defaults : 
      bb_view_model_defaults
    mapping :
      color : 'color'
      width : 'doubleSize'

    doubleSize : ->
      @model.get('size') * 2

  class BB_View_Model_Sync extends BB_View_Model_Base
    initialize : ->
      @model.on 'change', @update

  class BB_View_Model_AutoSync extends BB_View_Model_Base
    autoupdate : on

  class BB_View_Model_Ench extends BB_View_Model_AutoSync
    model : BB_Model_Base

  beforeEach ->
    bbObj = new BB_Model_Base

    $ = cheerio.load '<div id="content"></div>'

  describe '#new()', ->

    it 'should return Backbone.ViewModel object', ->
      tObj  = new BB_View_Model_Base bbObj
      tObj.should.to.be.an.instanceof Backbone.ViewModel

    it 'should throw error if model as first argument is missed', ->
      expect(-> new BB_View_Model_Base).to.throw /model or raw data required/

    it 'should use default properties (as BB model)', ->
      tObj  = new BB_View_Model_Base bbObj
      expect(tObj.get 'border').to.be.true
      expect(tObj.get 'radius').to.be.equal bb_view_model_defaults.radius

    it 'should use constructor attr for properties (second parameter)', ->
      tObj  = new BB_View_Model_Base bbObj, constructor_options
      expect(tObj.get 'radius').to.be.equal constructor_options.radius
      expect(tObj.get 'color').to.be.equal bb_model_defaults.color

    it 'should overwrite default attr properties with constructor attrs', ->
      tObj  = new BB_View_Model_Base bbObj, constructor_options
      expect(tObj.get 'radius').to.be.equal constructor_options.radius

    it 'should always overwrite any attr properties with mapped one', ->
      tObj  = new BB_View_Model_Base bbObj, constructor_options
      expect(tObj.get 'width').to.be.equal bb_model_defaults.size * 2

    it 'should be create object with raw data if \'model\' property exist', ->
      tObj  = new BB_View_Model_Ench bb_model_defaults

      expect(tObj.get 'color').to.be.equal bb_model_defaults.color
      expect(tObj.get 'width').to.be.equal bb_model_defaults.size * 2
      expect(tObj.model.getSize()).to.be.equal bb_model_defaults.size

    it 'should be create object with base Backbone.Model if raw data passed but \'model\' property omitted', ->
      tObj  = new BB_View_Model_Base bb_model_defaults

      expect(tObj.get 'color').to.be.equal bb_model_defaults.color
      expect(tObj.get 'width').to.be.equal bb_model_defaults.size * 2
      expect(-> tObj.model.getSize()).to.throw /has no method/

  describe 'mapping (class property)', ->

    it 'should map viewmodel attribute to view attribute', ->
      tObj  = new BB_View_Model_Base bbObj
      expect(tObj.get 'color').to.be.equal bb_model_defaults.color

    it 'should map viewmodel attribute to computed property', ->
      tObj  = new BB_View_Model_Base bbObj
      expect(tObj.get 'width').to.be.equal bb_model_defaults.size * 2

    it 'should throw error if view model try to map unknown thing', ->

      BB_View_Model_Err = class BB_View_Model_Err extends Backbone.ViewModel
        mapping :
          color : 'bright'

      expect(-> new BB_View_Model_Err bbObj).to.throw /can`t map/

    it 'should map viewmodel attribute to view attribute as deep clone', ->

      # we are need it for make test possible
      BB_Model_Base = class BB_Model_Base extends Backbone.Model
        defaults : 
          _.cloneDeep bb_model_defaults

      BB_View_Model = class BB_View_Model extends Backbone.ViewModel
        mapping :
          deep : 'deep'

      bbObj = new BB_Model_Base

      tObj  = new BB_View_Model bbObj
      deep = bbObj.get 'deep'
      # now change deep value
      deep.value = true

      expect(tObj.get 'deep').not.to.be.eql bbObj.get 'deep'
      tObj.get('deep').value.should.to.be.false

    it 'should map viewmodel attribute as computed as deep clone', ->

      # we are need it for make test possible
      BB_Model_Base = class BB_Model_Base extends Backbone.Model
        defaults : 
          _.cloneDeep bb_model_defaults

      BB_View_Model = class BB_View_Model extends Backbone.ViewModel
        mapping :
          deep : 'getDeep'
        getDeep : ->
          @model.get 'deep'

      bbObj = new BB_Model_Base
      tObj  = new BB_View_Model bbObj

      deep = bbObj.get 'deep'
      # now change deep value
      deep.value = true

      expect(tObj.get 'deep').not.to.be.eql bbObj.get 'deep'
      tObj.get('deep').value.should.to.be.false

  describe '#update()', ->

    it 'should not update viewmodel attribute without update()', ->
      tObj  = new BB_View_Model_Base bbObj
      bbObj.set 'color', 'blue'

      tObj.get('color').should.not.to.be.eql 'blue'
      
    it 'should update viewmodel attribute from view attribute', ->
      tObj  = new BB_View_Model_Base bbObj
      bbObj.set 'color', 'blue'
      tObj.update()
      
      tObj.get('color').should.to.be.eql 'blue'

    it 'should update viewmodel attribute with computed property', ->
      tObj  = new BB_View_Model_Base bbObj
      bbObj.set 'size', 100
      tObj.update()
      
      tObj.get('width').should.to.be.eql 100*2

    it 'should trigger "change" event', (done) ->
      tObj  = new BB_View_Model_Base bbObj
      bbObj.set 'size', 100

      tObj.on 'change', -> done()
      tObj.update()

    it 'should support \'autoupdate\' property in constructor', ->
      tObj  = new BB_View_Model_Base bbObj, {}, autoupdate : true
      bbObj.set 'size', 100

      tObj.get('width').should.to.be.eql 100*2

    it 'should support \'autoupdate\' property in ViewModel class', ->
      tObj  = new BB_View_Model_AutoSync bbObj
      bbObj.set 'size', 100

      tObj.get('width').should.to.be.eql 100*2

  describe 'as BB object', ->

    it 'should work as Model in Backbone.View', ->

      tObj  = new BB_View_Model_Sync bbObj

      MyView = class MyView extends Backbone.View
        template: _.template "<span><%= width %></span>"

        initialize: ->
          @listenTo @model, "change", @render
          @render()
          this

        render: ->
          @el.empty().append @template @model.attributes
          this

      my_view_inst = new MyView model : tObj, el : $('#content')
      
      $.html().should.to.be.equal '<div id="content"><span>90</span></div>'
      # and now change and get autoupdate
      bbObj.set 'size', 100
      $.html().should.to.be.equal '<div id="content"><span>200</span></div>'


    it 'should work as Model in Backbone.Collection', (done) ->

      loop_n = 2

      notified_vm_ids = []

      end_check = -> 
        notified_vm_ids.should.to.have.length loop_n
        done()

      end_check_once = _.after loop_n, end_check

      notification_fn = (evnt_obj) -> 
        notified_vm_ids.push evnt_obj.get 'id'
        end_check_once()

      MyCollection = class MyCollection extends Backbone.Collection

      my_collection_inst = new MyCollection _.times loop_n, (n) -> 
        new BB_View_Model_Sync bbObj, id : n

      my_collection_inst.on "change", notification_fn

      my_collection_inst.get(0).model.set 'size', 100
  

  describe 'should support some BB.Model methods (and other works too)', ->

    it '#toJSON()', ->
      tObj  = new BB_View_Model_Sync bbObj
      tObj.toJSON().should.to.be.eql tObj.attributes

    it '#get()', ->
      tObj  = new BB_View_Model_Sync bbObj
      tObj.get('width').should.to.be.eql bb_model_defaults.size * 2



