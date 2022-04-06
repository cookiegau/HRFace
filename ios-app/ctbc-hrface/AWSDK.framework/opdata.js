//
//  opdata.js
//  xsw-settings-providers-operationaldata
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//

const initScript = require('modules/ws1_staging.js');
const events = require('modules/events.js');
const syncEvent = events.event('sync_opdata_script');
const execEvent = events.event('exec_opdata_script');
const syncAndExecEvent = events.event('sync_exec_opdata_script');
var syncListener, execListener, syncAndExecListener, operationalData;

module.exports = {
    init: function(args){
        initScript.pinsResourcePath = "ws1_staging_pins.json";
        initScript.payloadName = args.opdataInitPayloadName || "init";
        initScript.payloadIdentifier = args.opdataInitPayloadID || "ws10per8t10nAlD8ta";
        initScript.stagingURL = args.opdataStagingURL || "https://api.staging.region.dpa0.org/api/v1/sdk/compliance/rules";
        initScript.storageDir = args.opdataScriptDirectory || "operational_data_scripts";
        initScript.ocspVerification = true;

        syncListener = syncEvent.addListener(function(){
            console.log('synchronize');
            if(!initScript.sync()){
                console.log("synchronize error");
            }
            console.log('synchronize done');
        });

        const self = this;
        execListener = execEvent.addListener(function(ctx){
            console.log('execute');
            self.operationalData = initScript.exec(ctx);
        });

        syncAndExecListener = syncAndExecEvent.addListener(function(ctx){
            console.log('synchronize and execute');
            if(!initScript.sync()){
                console.log("synchronize error");
            }

            self.operationalData = initScript.exec(ctx);
            console.log('synchronize and execute done');
        });
    },
    destroy: function(){
        syncEvent.removeListener(syncListener);
        execEvent.removeListener(execListener);
        syncAndExecEvent.removeListener(syncAndExecListener);
    },
    operationalData: operationalData
};
