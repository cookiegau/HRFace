//
//  config.js
//  xsw-chameleon
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//


/**
 *
 * @module config
 */

module.exports = {};

/**
 * Gets a json persisted json configuration
 * @param name {string} the configuration name
 * @param defaultConfig {Object} the default configuration
 * @return {null|{}}
 */
module.exports.get_config = function(name, defaultConfig){
    return _get_json(name) || defaultConfig;
};

/**
 * Sets a json persisted json configuration
 * @param name {string} name of configuration
 * @param config {Object} the json configuration
 * @return {boolean}
 */
module.exports.put_config = function(name, config){
    return _put_json(name, config);
};