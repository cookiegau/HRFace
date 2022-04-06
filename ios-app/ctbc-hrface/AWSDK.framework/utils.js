//
//  utils.js
//  xsw-chameleon
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//


/**
 * @module utils
 */

function merge(src, dest, filter){
    var i, k, v, filterRes, copyFn,
        keys = Object.keys(src);

    if(typeof filter === "function"){
        copyFn = function(dest1, k1, v1){
            filterRes = filter(k1, v1);
            if(filterRes === true){
                dest1[k1] = v1;
            }else if(typeof filterRes === "string"){
                dest[filterRes] = v1;
            }
        };
    }else{
        copyFn = function (dest1, k1, v1) {
            dest1[k1] = v1;
        };
    }

    for(i=0; i<keys.length; i++){
        k = keys[i];
        v = src[k];
        copyFn(dest, k, v);
    }
}

function is_string_empty(s){
    return s === null || s === undefined || (typeof s === "string" && s.trim().length === 0);
}

/**
 * Base64 encode data
 * @param data {string | Uint8Array}
 * @return {string} encoded data
 */
function base64_encode(data){
    return _base64_encode.apply(null, arguments);
}

/**
 * Base64 decode data
 * @param data {string}
 * @return {Uint8Array}
 */
function base64_decode(data){
    return _base64_decode.apply(null, arguments);
}

/**
 * HMAC 256
 * @param secret {Uint8Array | string} - HMAC secret
 * @param data {Uint8Array | string} - HMAC data
 * @return {Uint8Array} HMAC data
 */
function HMAC_256(secret, data){
    return _hmac(256, secret, data);
}

/**
 * Returns random data string
 * @param size {number} size of random data
 * @param seed {string} seed of random data
 * @return {string} random data
 */
function random_data(size, seed){
    return _random_data.apply(null, arguments);
}

function random_uuid(){
    return _random_uuid();
}

/**
 *
 * @param data {string | Uint8Array} SHA data
 * @param [size] {('SHA1' | 'SHA256' | 'SHA512')} SHA size
 */
function sha_data(data, size){
    if(size === 'SHA1'){
        return _sha_data(data, 1);
    }else if(size === 'SHA256'){
        return _sha_data(data, 256);
    }else if(size === 'SHA512'){
        return _sha_data(data, 512);
    }else{
        return _sha_data(data);
    }
}

/**
 *
 * @param path {string} SHA file path
 * @param [size] {('SHA1' | 'SHA256' | 'SHA512')} SHA size
 */
function sha_file(path, size){
    if(size === 'SHA1'){
        return _sha_file(path, 1);
    }else if(size === 'SHA256'){
        return _sha_file(path, 256);
    }else if(size === 'SHA512'){
        return _sha_file(path, 512);
    }else{
        return _sha_file(path);
    }
}

module.exports = {
    "merge": merge,
    "is_string_empty": is_string_empty,
    "base64_encode": base64_encode,
    "base64_decode": base64_decode,
    "HMAC_256": HMAC_256,
    "random_data": random_data,
    "random_uuid": random_uuid,
    "sha_data": sha_data,
    "sha_file": sha_file
};