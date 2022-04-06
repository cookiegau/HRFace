//
//  ocsp.js
//  xsw-chameleon
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//

/**
 * @module ocsp
 */

/** Read X509 certificate from DER data
 * @param data {Uint8Array | Int8Array} DER data
 * @return X509 certificate
 */
function X509_read(data){
    return _X509_read.apply(null, arguments);
}

/** Read X509 certificate from PEM data
 * @param data {Uint8Array | Int8Array | string} PEM data
 * @return X509 certificate
 */
function X509_read_PEM(data){
    return _X509_read_PEM.apply(null, arguments);
}

/** OCSPResponse type definition
 * @typedef {Object} OCSPResponse
 * @property {string} revocation_status - revocation status
 * @property {string} [validation_error] - validation error
 */

/** OCSP validation
 * @param leafCertificate leaf X509 certificate
 * @param rootCertificate root X509 certificate
 * @param {number} [timeout] time to wait for OCSP response
 * @return OCSPResponse
 */
function OCSP_validate(leafCertificate, rootCertificate, timeout){
    return _OCSP_validate.apply(null, arguments);
}

module.exports = {
    "X509_read": X509_read,
    "X509_read_PEM": X509_read_PEM,
    "OCSP_validate": OCSP_validate
};