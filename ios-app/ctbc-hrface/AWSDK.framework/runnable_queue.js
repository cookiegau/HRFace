//
//  runnable_queue.js
//  xsw-chameleon
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//


RunnableQueue = {
    timer: null,
    callbacks: {}
};
RunnableQueue.register = function (id, fn) {
    var listeners = this.callbacks[id];
    if (!listeners) {
        listeners = this.callbacks[id] = [];
    }
    listeners.push(fn);
};

RunnableQueue.unregister = function (id, fn) {
    var idx, listeners = this.callbacks[id];
    if (listeners) {
        idx = listeners.indexOf(fn);
        if (idx !== -1) {
            listeners.splice(idx, 1);
        }
        if (listeners.length === 0) {
            delete this.callbacks[id];
        }
    }
};

RunnableQueue.fireCallback = function (id, data) {
//    print("fireCallback "+id+", data="+data.error);

    var i, len,
        listeners = this.callbacks[id];
    if (listeners) {
        len = listeners.length;
        for (i = 0; i < len; i++) {
            listeners[i](id, data);
        }
    }
};

RunnableQueue.timer = setInterval(function(){
    _process_runnable_queue();
}, 500);


