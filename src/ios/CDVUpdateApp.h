#import <Cordova/CDVPlugin.h>

@interface CDVUpdateApp : CDVPlugin

- (void)getCurrentVersion:(CDVInvokedUrlCommand*)command;
- (void)getServerVersion:(CDVInvokedUrlCommand*)command;
- (void)checkAndUpdate:(CDVInvokedUrlCommand*)command;

@end