jest.autoMockOff()

fakeEvent      = require 'synthetic-dom-events'
KDEventEmitter = require 'kdf-event-emitter'

KDDomDelegator   = require '../src/dom-event-delegator'
defaultEventList = require '../src/default-events'

describe 'KDDomDelegator', ->

  it 'works', -> expect(KDDomDelegator).toBeDefined()

  describe '.getInstance', ->

    it 'returns a KDDomDelegator instance', ->

      delegator = KDDomDelegator.getInstance()
      expect(delegator instanceof KDDomDelegator).toBe true


    it 'returns a singleton', ->

      firstDelegator = KDDomDelegator.getInstance()
      secondDelegator = KDDomDelegator.getInstance()

      expect(firstDelegator).toBe secondDelegator


  describe '#constructor', ->

    it 'has an node event registry', ->

      delegator = new KDDomDelegator
      expect(delegator._nodeEventRegistry).toBeDefined()


  describe '#registerNode', ->

    it 'registers dom node with kdnode', ->

      delegator = new KDDomDelegator

      domNode = document.createElement('div')
      kdNode = new KDEventEmitter

      delegator.registerNode domNode, kdNode

      expected = delegator._nodeEventRegistry.get domNode

      expect(expected).toBe kdNode


  describe '#forwardGlobalDOMEvents', ->

    delegator = new KDDomDelegator

    domElement = document.createElement('div')
    domElement.className = 'kdNode'
    document.body.appendChild domElement

    view = new KDEventEmitter
    delegator.registerNode domElement, view

    it 'adds single event listeners for each dom event to be able to delegate', ->

      result = {}

    for event in defaultEventList
      event = 'click'
      flag = off
      view.on event, -> flag = on
      e = fakeEvent event, {bubbles: yes}
      domElement.dispatchEvent e

      console.log {event}  unless flag # can write descriptions to tests.
      expect(flag).toBe on


  xdescribe '#forwardDOMEvent', ->

    it 'bubbles up event to parent nodes', ->

      delegator = new KDDomDelegator

      parent = new KDView { tagName: 'div' }
      child = new KDView { tagName: 'span', partial: 'fooo' }
      parent.addSubview child

      parent.domElement = document.createElement 'div'
      child.domElement = document.createElement 'span'
      parent.domElement.appendChild child.domElement

      delegator.registerNode parent.domElement, parent
      delegator.registerNode child.domElement, child

      document.body.appendChild parent.domElement

      flag = off
      parent.on 'click', -> flag = on

      e = fakeEvent 'click'

      child.domElement.dispatchEvent e

      expect(flag).toBe on


