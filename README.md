## KDDomEventDelegator

A module that communicates DOM events to `KDEventEmitter` instances.

## Motivation

For handling DOM events we wanted to touch to DOM as little as possible,
and we already have a definition of events in our environment in the form of
`KDEventEmitter` instances. But we needed to do this as efficient and performant as
possible without us requiring to think about `DOM` events in the `DOM` context rather
than `KDFramework` context.

This module uses a `WeakMap` as underlying data structure, and registers DOM elements
as keys and `KDEventEmitter` instances as values. So theoretically it's an `O(1)` operation
to get associated instance with the DOM element.

## Example

```coffee
KDEventEmitter      = require 'kdf-event-emitter'
KDDomEventDelegator = require 'kdf-dom-event-delegator'

# Ideally you would want only one delegator
# per app, so you would user `.getInstance()`
# class method to get singleton instance of this class.
# delegator = KDDomEventDelegator.getInstance()
delegator = new KDDomEventDelegator()

# will use dom delegator to forward
# DOM events on `domElement` to `kdNode`
domElement = document.createElement 'div'
kdNode     = new KDEventEmitter

# We created a listener on kdNode object.
kdNode.on 'click', (event) ->
  console.log 'clicked!'

# after this call all of the click events
# that happen on domElement, will be forwarded
# to kdNode.
delegator.registerNode domElement, kdNode

clickEvent = new MouseEvent 'click', { 'bubbles': yes }
domElement.dispatchEvent clickEvent
# => 'clicked!'
```

## What is happening here?

What it actually does is, it creates single event listeners for `defaultEvents` on the `document.documentElement`, and captures them on `capture` phase. And gets the dom element by using `event.target` property. And from there gets the kdNode from the registry, and emits a `KDEventEmitter` instance event.

It doesn't end there. If it is also a `KDViewNode` instance, it starts the bubbling of the event inside of the `KDDomTree`. It gives us the ability to use a unified interface for DOM Events.


## Installation

```
npm install kdf-dom-event-delegator
```

