//
//  scep.js
//  xsw-chameleon
//
//  Copyright © 2020 VMware, Inc. All rights reserved. This product is protected
//  by copyright and intellectual property laws in the United States and other
//  countries as well as by international treaties. VMware products are covered
//  by one or more patents listed at http://www.vmware.com/go/patents.
//


/**
 *
 * @module scep
 */

function enroll(url, enrollment, fn) {
    const id = _SCEP_enroll(url, enrollment);
    const listenerFn = wrapListener(url, enrollment, fn);
    print("register scep enrollment "+id+" to runnable queue");
    RunnableQueue.register(id, function (_id, _data) {
        print("scep enroll callback id="+_id+", data="+_data);
        listenerFn(_data);
        RunnableQueue.unregister(id, this);
    });
    return id;
}

function poll(url, enrollment, pendingPath, fn) {
    const id = _SCEP_poll(url, enrollment, pendingPath);
    const listenerFn = wrapListener(url, enrollment, fn);
    print("poll scep enrollment "+id);
    RunnableQueue.register(id, function (_id, _data) {
        print("poll scep callback id="+_id+", data="+_data);
        listenerFn(_data);
        RunnableQueue.unregister(id, this);
    });
    return id;
}

function wrapListener(url, enrollment, fn){

    enrollment.pending_retries = enrollment.pending_retries || 0;
    enrollment.pending_max_retries = enrollment.pending_max_retries || 10;
    enrollment.pending_interval = enrollment.pending_interval || 5000;

    return function(res){
        print("scep listener called with res="+JSON.stringify(res));
        if(res.pending_path !== undefined && enrollment.pending_retries < enrollment.pending_max_retries) {
            print("scep poll retry "+enrollment.pending_retries+" interval="+enrollment.pending_interval+", max_retries="+enrollment.pending_max_retries);
            setTimeout(function(){
                poll(url, enrollment, res.pending_path, fn);
            }, enrollment.pending_interval);
            enrollment.pending_retries++;
        }else{
            print("scep listener finished");
            fn(res);
        }
    };
}

module.exports = {
    "enroll": enroll,
    "poll": poll
};