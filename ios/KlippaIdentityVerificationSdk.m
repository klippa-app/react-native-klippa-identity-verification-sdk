#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(KlippaIdentityVerificationSdk, NSObject)

RCT_EXTERN_METHOD(startSession:(NSDictionary *)config
                 withToken:(NSString)sessionToken
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)


+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

@end
