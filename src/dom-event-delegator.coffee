WeakMap = require 'weakmap'

defaultEventList = require './default-events'

module.exports = class KDDomEventDelegator

  ###*
   * Private singleton instance of dom delegator.
   *
   * @type {KDDomEventDelegator}
   * @api private
  ###
  instance = null


  ###*
   * Returns the singleton instance, if `singleton` is not
   * initialized, initalizes the it.
   *
   * @return {KDDomEventDelegator} instance - singleton instance
  ###
  @getInstance: -> instance or= new KDDomEventDelegator


  ###*
   * @param {Object=} options
   * @param {DOMDocument=} options.document - will be used for binding events.
   * @param {Array.<String>=} globalEvents - array of event names to listen globally
   * @param {Boolean=} lazy - if yes, global listeners won't get init'd.
  ###
  constructor: (options = {}) ->

    options.lazy ?= no

    ###* @type {WeakMap} ###
    @_nodeEventRegistry = new WeakMap

    ###* @type {DOMDocument} ###
    @doc = options.document or document

    ###* @type {Array.<String>} ###
    @globalEvents = options.globalEvents or defaultEventList

    @forwardGlobalDOMEvents()  unless options.lazy


  ###*
   * Attaches one single event listener for each event name
   * in `globalEvents` list. (e.g one listener for 'click', one
   * listener for 'dblclick' etc.
  ###
  forwardGlobalDOMEvents: ->

    @forwardDOMEvent @doc.documentElement, event, yes  for event in @globalEvents


  ###*
   * Heart of the `KDDomEventDelegator`. what this method
   * simply does is that it adds an event listener to the given
   * element, and when this element receives an event with the type of
   * given event name, it emits it to the kd node pair of event's target.
   * With this solution, if we have a map of all the dom tree present,
   * we can let the bubbling part to regular dom api, because when a parent
   * dom node recieves a bubble event from a child, we already have it's
   * corresponding kd node in our registry, so it will emit the same event
   * to the parent kd node as well. With the useage of Weakmaps, hopefully
   * this operation will be really fast.
   *
   * @param {DOMElement} element - DOM element to listen events to.
   * @param {String} eventName - Event name to listen.
   * @param {Boolean} capturePhase
  ###
  forwardDOMEvent: (element, eventName, capturePhase = no) ->

    element.addEventListener eventName, (event) =>

      target = event.target or event.srcElement
      kdNode = @getNode target

      event.stopPropagation = -> event.cancelBubble = yes

      node = kdNode

      while node

        event.currentTarget = node.domElement

        listener = node._e?[eventName]

        node.emit eventName, event  if listener?

        node = if event.cancelBubble then null else node.parent

    , capturePhase


  ###*
   * Adds a {<DOMElement>: <KDEventEmitter>} pair to node event registry.
   *
   * @param {DOMElement} domElement - its events will be forwarded to kd node pair.
   * @param {KDEventEmitter} kdNode - an emitter instance to forward events from dom.
  ###
  registerNode: (domElement, kdNode) ->

    @_nodeEventRegistry.set domElement, kdNode


  ###*
   * Removes given dom element from registry.
   *
   * @param {DOMElement} domElement
  ###
  unregisterNode: (domElement) ->

    @_nodeEventRegistry.delete domElement


  ###*
   * Returns kd node pair of dom element.
   *
   * @param {DOMElement} domElement
  ###
  getNode: (domElement) ->

    @_nodeEventRegistry.get domElement


  ###*
   * Check to see if a dom element is being listened by delegator.
   *
   * @param {DOMElement} domElement
  ###
  hasNode: (domElement) ->

    @_nodeEventRegistry.has domElement


