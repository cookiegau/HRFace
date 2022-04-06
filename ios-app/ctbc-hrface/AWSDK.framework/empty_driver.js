//
//  empty_driver.js
//  xsw-chameleon
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//

driver = (function () {
    function init() {
    }

    function destroy() {
    }

    print("EmptyDriver has been loaded");

    return {
        "init": init,
        "destroy": destroy
    };

})();