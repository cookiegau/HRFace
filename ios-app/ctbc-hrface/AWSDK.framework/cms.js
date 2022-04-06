//
//  cms.js
//  xsw-chameleon
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//


/**
 *
 * @module cms
 */

module.exports = {
    /** Read CMS content
     * @param content {string | Uint8Array}
     * @param decrypt {boolean}
     * @return {string} verified/decrypted cms content
     */
    read_cms_content: function(content, decrypt) {
        return _read_cms_content(content, decrypt);
    },
    /** Evaluates a signed or encrypted script using the key and trust store
     * @param cmsContent {string | Uint8Array} signed or encrypted smime content
     * @param decrypt {boolean} true if the content is encrypted
     * @return {boolean} true if success
     */
    secure_eval: function(cmsContent, decrypt){
        return _secure_eval(cmsContent, decrypt);
    }
};


