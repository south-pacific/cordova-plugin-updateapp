#import <Cordova/CDVPlugin.h>

@interface CDVUpdateApp : CDVPlugin

- (void)getCurrentVerInfo:(CDVInvokedUrlCommand*)command;

@end