#import <Cordova/CDVPlugin.h>

@interface CDVUpdateApp : CDVPlugin

- (void)getCurrentVersion:(CDVInvokedUrlCommand*)command;

@end