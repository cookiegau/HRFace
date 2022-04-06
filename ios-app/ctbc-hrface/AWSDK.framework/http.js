//
//  http.js
//  xsw-chameleon
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//


/**
 *
 * @module http
 */

module.exports = {};

const config = require('modules/config.js');
const fs = require('modules/fs.js');
const url = require('modules/url.js');

/**
 * HttpRequest type definition
 * @typedef {Object} HttpRequest
 * @property {string} url - endpoint URL
 * @property {Uint8Array | string | undefined} [body] - the body data
 * @property {('GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH')} method - http method
 * @property {Array.<string>} [headers] - http headers
 * @property {Array.<string>} [pinned_public_keys] - public key pins required for successful connection
 * @property {number} [pinned_public_key_index] index of the key in the certificate chain. 0 = leaf, 1 = parent CA
 * @property {string} [ca_cert_path] - path to CA file in PEM format
 * @property {string} [key_store_path] - path to client P12 store
 * @property {string} [key_store_pass] - client private key password for P12 store
 */

/**
 * HttpResponse type definition
 * @typedef {Object} HttpResponse
 * @property {int} status - http status
 * @property {string} content - content
 * @property {string} content_type - content type
 * @property {Map.<string, string>} headers - http headers
 */

/**
 * @callback HttpStreamCallback
 * @param {string} streamId - stream ID
 * @param {string} streamData - stream data
 */

/**
 * Starts listening to the http stream
 * @function
 * @param req {HttpRequest} - http request
 * @param fn {HttpStreamCallback} - http stream callback
 * @returns {string} streamId - handle for http stream used for stopping stream
 */
module.exports.start_stream = function(req, fn) {
    var streamId = _start_http_stream(req);
    RunnableQueue.register(streamId, fn);
    return streamId;
};

/**
 * Stops listening to the http stream
 * @function
 * @param streamId - stream ID
 * @param fn {HttpStreamCallback} - original callback register with start_http_stream
 */
module.exports.stop_stream = function(streamId, fn) {
    _stop_http_stream(streamId);
    RunnableQueue.unregister(streamId, fn);
};

/**
 * @callback HttpDownloadCallback
 * @param {string} downloadId - download ID
 * @param {string} downloadLocation - file download location
 */

/**
 * Download over http
 * @param req {HttpRequest} - http request
 * @param destination {string} - download file destination
 * @param fn {HttpDownloadCallback}
 */
module.exports.download = function(req, destination, fn){
    var id = _async_http_download(req, destination);
    RunnableQueue.register(id, function(eventId, data){
        fn(eventId, data);
        RunnableQueue.unregister(eventId, this);
    });
};

function invoke_request(request){
    return _http_request(request);
}

/**
 * Makes a HTTP request
 * @function
 * @param request {HttpRequest}
 * @returns HttpResponse
 */
module.exports.request = invoke_request;


/**
 * HTTP request that support ETag caching
 * @param request {HttpRequest} the http request
 * @param storageDir [string] content storage directory
 * @return {HttpResponse} response
 */
module.exports.cache_request = function(request, storageDir){
    var file;
    const etags = config.get_config("etags", {});

    if(!request.headers){
        request.headers = [];
    }

    if(etags[request.url]){
        request.headers.push('If-None-Match: ' + etags[request.url]);
    }
    const response = invoke_request(request);

    if (response.status === 304) {
        print('cache_request: content not modified... using cache');
        file = url.url_encode(request.url);
        if(storageDir){
            file = storageDir + "/" + file;
        }
        response.content = fs.read_file(file);
        response.status = 200;
    }else if(response.status === 204){
        response.content = '';
    }else if (response.status === 200) {
        Object.keys(response.headers).forEach(function (key) {
            var etag;
            if (key.toLowerCase() === 'etag') {
                etag = response.headers[key];
                file = url.url_encode(request.url);
                if(storageDir){
                    file = storageDir + "/" + file;
                }
                const success = fs.write_file(file, response.content);
                if (success) {
                    etags[request.url] = etag;
                    config.put_config("etags", etags);
                }
            }
        });
    }else{
        throw Error('could not fetch content status='+response.status);
    }
    return response;
};


