//
//  secure_scripting.js
//  xsw-chameleon
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//


/**
 *
 * @module remote_scripting
 */

const http = require('modules/http.js');
const cms = require('modules/cms.js');
const fs = require('modules/fs.js');

module.exports = {};

/**
 * Imports a module from CMS content that is signed and/or encrypted
 * @param content {string | Uint8Array} path pointing to CMS script content
 * @param [decrypt] {boolean} true if the content is encrypted
 * @return {Object} the module exports
 */
import_module_content = module.exports.import_module_content = function(content, decrypt) {

    const cms_content = cms.read_cms_content(content, decrypt);

    var script = "(function(module){\n";
    script += cms_content['content'];
    script += "\nreturn module.exports;\n" +
        "})({});";

    const exp = eval(script);

    // Only enable for debugging or testing.
    // print("import_module_content exports=", JSON.stringify(exp), ", script=\n", script);

    return exp;
};

/**
 * Evaluates a signed or encrypted script using the key and trust store
 * @param cmsContent {string | Uint8Array} signed or encrypted smime content
 * @param decrypt {boolean} true if the content is encrypted
 * @return {boolean} true if success
 */
module.exports.secure_eval = function(cmsContent, decrypt){
    return _secure_eval(cmsContent, decrypt);
};
/**
 * Evaluates a CMS signed or encrypted script from url using key and trust store
 * @param request {string | HttpRequest} url pointing to CMS script content
 * @param [storageDir] {string} storage directory for cached scripts
 * @param [decrypt] {boolean} true if the content is encrypted
 * @return {boolean} true if success
 */
module.exports.secure_eval_url = function(request, storageDir, decrypt){
    var req;
    if(typeof req === 'string') {
        req = { 'url': req };
        req.method = "GET";
        req.headers = ["Accept: application/pkcs7-signature, application/pkcs7-mime"];
    }else{
        req = request;
        req.headers = ["Accept: application/pkcs7-signature, application/pkcs7-mime"];
    }
    if(storageDir){
        fs.mkdir(storageDir);
    }
    const res = http.cache_request(req, storageDir);
    return res.status === 200 && secure_eval(res.content, decrypt);
};


/**
 * Imports a module from a url that is signed and/or encrypted using CMS
 * @param request {string | HttpRequest} url pointing to CMS script content
 * @param [storageDir] {string} storage directory for cached scripts
 * @param [decrypt] {boolean} true if the content is encrypted
 * @return {Object} the module exports
 */
module.exports.import_module_url = function(request, storageDir, decrypt){
    var req;
    if(typeof request === 'string') {
        req = { 'url': request };
        req.method = "GET";
        req.headers = ["Accept: application/pkcs7-signature, application/pkcs7-mime"];
    }else{
        req = request;
        req.headers = ["Accept: application/pkcs7-signature, application/pkcs7-mime"];
    }

    if(storageDir){
        fs.mkdir(storageDir);
    }
    const res = http.cache_request(req, storageDir);
    const cmsMessage = res.status === 200 ? res.content : false;

    if(!cmsMessage || cmsMessage.length === 0){
        print('could not read cms message');
        return false;
    }

    return import_module_content(cmsMessage, decrypt);
};

/**
 * Imports a module from a file path that is signed and/or encrypted using CMS
 * @param filePath {string} path pointing to CMS script content
 * @param [decrypt] {boolean} true if the content is encrypted
 * @return {Object} the module exports
 */
module.exports.import_module_path = function(filePath, decrypt){
    const cmsMessage = fs.read_file(filePath, false);

    if(!cmsMessage || cmsMessage.length === 0){
        print('could not read cms message');
        return false;
    }

    return import_module_content(cmsMessage, decrypt);
};


