//
//  settings.js
//  xsw-chameleon
//
//  Copyright © 2016 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//

var events = require("events");

var GeneratorFactory = (function(){
    function Generator() {
        this.current = 0;
        this.next = function() {
            return ++this.current;
        }
    }

    var instance;
    return {
        getInstance: function() {
            // check if instance is available
            if (!instance) {
                instance = new Generator();
                delete instance.constructor; // or set it to null
            }
            return instance;
        }
    };
})();

Settings.prototype = {
    "name": ""
};

function Settings(name){
    this.name = name;
}

Settings.withName = function(name) {
    return new Settings(name)
}

Settings.prototype._async = function(callable) {
    if(typeof(callable) === 'function') {
        var g = GeneratorFactory.getInstance();
        var i = g.next();

        var name =  "asm_events_" + i;

        var handle = null;
        var proxy = function(msg) {
            callable.apply(null, Array.prototype.slice.call(arguments));
            events.event(name).removeListener(handle);
        }
        handle = events.event(name).addListener(proxy);

        return name;
    }
    return undefined;
};

Settings.prototype.get = function(keypath, defaultValue) {
    if(typeof defaultValue !== "undefined") {
        return asm_getWithDefault(this.name, keypath, defaultValue);
    }
    return asm_get(this.name, keypath)
};

Settings.prototype.getWithCallback = function(keypath, defaultValue, callable) {
    var event = this._async(callable);
    asm_getWithCallback(this.name, keypath, defaultValue, event);
};

Settings.prototype.set = function(keypath, value) {
    return asm_set(this.name, keypath, value)
};

Settings.prototype.setWithCallback = function(keypath, value, callable) {
    var event = this._async(callable);
    return asm_setWithCallback(this.name, keypath, value, event)
};

Settings.prototype.remove = function(keypath) {
    return asm_remove(this.name, keypath)
};

Settings.prototype.removeWithCallback = function(keypath, callable) {
    var event = this._async(callable);
    return asm_removeWithCallback(this.name, keypath, event)
};

Settings.prototype.exists = function(keypath) {
    return asm_exists(this.name, keypath)
};

Settings.prototype.existsWithCallback = function(keypath, callable) {
    var event = this._async(callable);
    return asm_existsWithCallback(this.name, keypath, event)
};

Settings.prototype.count = function(keypath) {
    return asm_count(this.name, keypath)
};

Settings.prototype.countWithCallback = function(keypath, callable) {
    var event = this._async(callable);
    return asm_countWithCallback(this.name, keypath, event)
};

Settings.prototype.custom = function(cmd, keypath, arg) {
    return asm_custom(this.name, cmd, keypath, arg)
};

Settings.prototype.customWithCallback = function(cmd, keypath, arg, callable) {
    var event = this._async(callable);
    return asm_customWithCallback(this.name, cmd, keypath, arg, event)
};

function getWithName(name) {
    return Settings.withName(name);
}

module.exports = {
    "getWithName": getWithName,
    "Settings": Settings
};