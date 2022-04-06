//
//  events.js
//  xsw-chameleon
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//


/**
 *
 * @module events
 */

/**
 * Event listener callback
 * @callback ChameleonEventListener
 * @param {Object|string} data - data returned
 *
 */

/**
 * Event listener handle used to remove
 * @typedef {Object} ChameleonEventListenerHandle
 * @property {string} id - listener id
 * @property {ChameleonEventListener} fn - function callback
 */

/**
 * @class
 * @param id {string} - event id
 * @constructor
 */
function Event(id){
    this.eventId = id;
}

/**
 * Adds a listener to event
 * @param fn {ChameleonEventListener} - listener callback
 * @returns {ChameleonEventListenerHandle} - the event listener handle
 */
Event.prototype.addListener = function(fn){
    var wrapperFn = function(id, data){
        fn(data);
    };
    RunnableQueue.register(this.eventId, wrapperFn);
    //increment event count to optimize driver
    _increment_event(this.eventId);

    return {
        id: this.eventId,
        fn: wrapperFn
    };
};
/**
 * Removes listener for event
 * @param {ChameleonEventListenerHandle} handle - the listener handle
 */
Event.prototype.removeListener = function(handle){
    RunnableQueue.unregister(handle.id, handle.fn);
    //decrement event count so no unnecessary events get dispatched when no listeners
    _decrement_event(this.eventId);
};

module.exports = {
    /**
     * Creates new event object
     * @param eventId {string} - the event id
     * @returns {Event}
     */
    "event": function(eventId){
        return new Event(eventId);
    },
    /**
     * Process the events
     * @return {*}
     */
    "process": function(){
        return _process_runnable_queue();
    }
};