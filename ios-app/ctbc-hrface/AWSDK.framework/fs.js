//
//  fs.js
//  xsw-chameleon
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//


/**
 * Basic filesystem functions
 * @module fs
 */


module.exports = {
    /**
     * Read content from a file
     * @param path {string} file path
     * @param [encrypted] {boolean} is file encrypted. default is encrypted
     * @return {Uint8Array} file content
     */
    read_file: function (path, encrypted) {
        return _read_file(path, encrypted);
    },

    /**
     * Read content from a resource
     * @param path {string} resource path
     * @param [is_json] {boolean} optional flag to indicate resource is JSON. default is false
     * @return {Uint8Array | Object} file content
     */
    read_resource: function (path, is_json) {
        return _read_resource(path, is_json);
    },

    /**
     * Write content to a file
     * @param path {string} file path
     * @param data {string | Uint8Array} data
     * @param [encrypt] {boolean} encrypt the data. default is to encrypt
     */
    write_file: function (path, data, encrypt) {
        return _write_file(path, data, encrypt);
    },

    /**
     * Make filesystem directory
     * @param path
     * @throws Error
     */
    mkdir: function (path) {
        return _mkdir(path);
    }
};