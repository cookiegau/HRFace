//
//  AWCMWrapperModule.h
//  AWOpenSSL
//
// Copyright © 2019 VMware, Inc. All rights reserved.
// This product is protected by copyright and intellectual property laws in the United States and
// other countries as well as by international treaties.
// AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
//


#import <Foundation/Foundation.h>

#define PRINT_MODULE_USAGE_GUIDELINES(message) if (AWCMWrapperModule.ready == NO) { NSLog(message); }

NS_ASSUME_NONNULL_BEGIN

@interface AWCMWrapperModule : NSObject

/**
 Class method to return whether this module is ready overall,

 @return true if the module is ready and can make various API calls.
 */
@property(atomic, class, readonly, getter=isReady) BOOL ready;

/**
 Class method to make the module ready before other API Usage.
 */
+(void) makeModuleReadyWithCompletion:(nullable dispatch_block_t) completion;

@end

@interface AWCMWrapperModuleAPIObject : NSObject

@end
NS_ASSUME_NONNULL_END
