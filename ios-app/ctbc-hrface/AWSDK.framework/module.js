//
//  module.js
//  xsw-chameleon
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//


Duktape.modSearch = function (id, require, exports, module) {
    /* readFile() reads a file from disk, and returns a string or undefined.
     * 'id' is in resolved canonical form so it only contains terms and
     * slashes, and no '.' or '..' terms.
     */
    print('loading module: id=', id, ', require=', require, ', exports=', JSON.stringify(exports), ', module=', JSON.stringify(module));

    try {
        if(id.endsWith(".js")){
            module.filename = id;
        }else{
            module.filename = 'modules/' + id + '.js';
        }
        /**
         * @type Uint8Array
         */
        const res = _read_resource(module.filename);

        if (typeof res === 'object') {
            return new TextDecoder().decode(res);
        }
    }catch(e){
        print("error loading module: ", e);
        throw new Error('error loading module: ' + e);
    }

    throw new Error('module not found: ' + id);
};
