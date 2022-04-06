//
//  url.js
//  xsw-chameleon
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//


/**
 *
 * @module url
 */

module.exports = {
    /**
     * Base64 url encode data
     * @param data {string | Uint8Array}
     * @return {string} encoded data
     */
    base64_url_encode: function (data) {
        return _base64_url_encode(data);
    },

    /**
     * Base64 url decode data
     * @param data {string}
     * @return {Uint8Array}
     */
    base64_url_decode: function (data) {
        return _base64_url_decode(data);
    },

    /**
     * url encode data
     * @param data {string | Int8Array}
     * @return {string}
     */
    url_encode: function (data) {
        return _url_encode(data);
    },

    /**
     * url decode data
     * @param data {string | Int8Array}
     * @return {string}
     */
    url_decode: function (data) {
        return _url_decode(data);
    },

    /**
     * url encode form
     * @param form {object} form containing key/value pairs
     * @return {string} url encoded form (application/x-www-form-urlencoded)
     */
    url_encode_form: function (form) {
        var str = "";
        const me = this;
        Object.keys(form).forEach(function (key, idx) {
            str += me.url_encode(key) + "=" + me.url_encode(form[key]);
            console.log(str);
            if (idx + 1 < str.length) {
                str += '&';
            }
        });
        return str.substring(0, str.length - 1);
    }

};

