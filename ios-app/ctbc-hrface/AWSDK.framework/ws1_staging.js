//
//  ws1_staging.js
//  xsw-chameleon
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//


/**
 * @module ws1_staging
 */

const http = require('modules/http.js');
const utils = require('modules/utils.js');
const fs = require('modules/fs.js');
const sscript = require('modules/secure_scripting.js');
const cms = require('modules/cms.js');
const ocsp = require('modules/ocsp.js')

/**
 * @param smimeText
 * @return {{verified: boolean, cms: string}}
 */
function verifyScript(smimeText){
    try {
        const cms_content = cms.read_cms_content(smimeText);
        return { verified: true, cms: cms_content };
    }
    catch(e) {
        console.log('verifyScript failed ', e);
    }

    return { verified: false, cms: undefined };
}

/**
 * @typedef RulesPayload
 * @property {string} payload
 * @property {string} payloadVersion
 */

/**
 * @typedef RulesDataPayload
 * @property {string} id
 * @property {RulesPayload} rules
 * @property {Date} created_at
 * @property {Date} created_by
 * @property {Date} modified_at
 * @property {Date} modified_by
 *
 */

/**
 *
 * @param {string} url base staging url
 * @param {string} payloadIdentifier payload identifier appended to url
 * @param {Array<string>} pins SHA256->base64 public key pins
 * @return {RulesDataPayload}
 */
function fetch(url, payloadIdentifier, pins){
    const payloadURL = (url || 'https://api.staging.region.dpa0.org/api/v1/sdk/compliance/rules') + '/' + payloadIdentifier;
    const res = http.request({
        url: payloadURL,
        pinned_public_keys: pins,
        pinned_public_key_index: 2,
        headers: [
            'Accept: application/json'
        ]
    });
    if(res.status !== 200){
        throw ('invalid status for staging rules payload status=' + res.status);
    }

    if(res.content_type !== 'application/json'){
        throw ('invalid content type for staging rules payload content-type=' + res.content_type);
    }

    const o = res.content;
    return o.data;
}

module.exports = {
    /**
     * Base staging URL without payload identifier
     * @type {string}
     */
    stagingURL: 'https://api.staging.region.dpa0.org/api/v1/sdk/compliance/rules',
    /**
     * Payload identifier from staging endpoint
     * @type {string}
     */
    payloadIdentifier: '',
    /**
     * Optional name of payload to be stored
     * @type {string | boolean}
     */
    payloadName: false,
    /**
     * Storage directory
     * @type {string}
     */
    storageDir: 'staging_scripts',

    /**
     * Resource path to JSON config with array of public key pins
     * @type {string}
     */
    pinsResourcePath: 'ws1_staging_pins.json',

    /**
     * OCSP verification done on synchronize.
     * @type {boolean}
     */
    ocspVerification: false,

    /**
     * Gets path to saved script
     * @return {string}
     */
    getScriptPath: function(){
        return this.storageDir + '/' + (this.payloadName || this.payloadIdentifier) + '.p7s';
    },

    /**
     * Fetch script from staging endpoint and persist signed script
     * @return {boolean} true if script was downloaded and verified
     */
    sync: function() {
        const pins = fs.read_resource(this.pinsResourcePath, true);
        const data = fetch(this.stagingURL, this.payloadIdentifier, pins);
        const b64Payload = data.rules.payload;
        //this should be a signed S/MIME text payload
        const smimeText = utils.base64_decode(b64Payload);

        const ret = verifyScript(smimeText);
        if(ret.verified) {

            var verified = false;
            if (this.ocspVerification) {
                const certificateChain = ret.cms['certificate_chain'];
                if (certificateChain.length > 2) {

                    const x509_leaf = certificateChain[0];
                    const x509_issuer = certificateChain[1];

                    const ocspValidate = ocsp.OCSP_validate(x509_leaf, x509_issuer, 10000);

                    if ('Good' === ocspValidate.revocation_status && '' === ocspValidate.validation_error) {
                        console.log('OCSP verification successful');
                        verified = true;
                    }
                    else {
                        console.log('OCSP verification failed');
                    }
                }

            }
            else {
                verified = true;
            }

            fs.mkdir(this.storageDir);
            const scriptPath = this.getScriptPath();

            return verified && fs.write_file(scriptPath, smimeText, false);
        }

        return false;
    },

    /**
     * Execute current script
     * @return {object} imported module
     */
    exec: function() {
        return sscript.import_module_path(this.getScriptPath());
    }

};

