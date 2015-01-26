#import "CDVUpdateApp.h"
#import <Cordova/CDVPluginResult.h>

@implementation CDVUpdateApp

NSString *ipaPath;

- (void)getCurrentVersion:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        NSString* version = [self getCurrentVersionCode];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:version];
        
        [self.commandDelegate evalJs:[pluginResult toSuccessCallbackString:command.callbackId]];
    }];
}

- (void)getVersionName:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        NSString* version = [self getCurrentVersionName];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:version];
        
        [self.commandDelegate evalJs:[pluginResult toSuccessCallbackString:command.callbackId]];
    }];
}

- (void)getServerVersion:(CDVInvokedUrlCommand*)command
{
    
    NSString *URL = [command argumentAtIndex:0];
    
    [self.commandDelegate runInBackground:^{
        NSDictionary *resultDic = [self getServerVersionCode:URL];
        
        if (resultDic == nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"error"];
            
            [self.commandDelegate evalJs:[pluginResult toErrorCallbackString:command.callbackId]];
        } else {
            NSString *lastVersion = [resultDic objectForKey:@"verName"];
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:lastVersion];
            
            [self.commandDelegate evalJs:[pluginResult toSuccessCallbackString:command.callbackId]];
        }
    }];
}

- (void)checkAndUpdate:(CDVInvokedUrlCommand*)command
{
    NSString *URL = [command argumentAtIndex:0];
    
    [self.commandDelegate runInBackground:^{
        NSDictionary *resultDic = [self getServerVersionCode:URL];
        
        if (resultDic) {
            NSString *lastVersion = [resultDic objectForKey:@"verName"];
            ipaPath = [resultDic objectForKey:@"ipaPath"];
            
            if ([lastVersion compare:[self getCurrentVersionCode] options:NSNumericSearch] == NSOrderedDescending) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"有新的版本，是否前往更新？" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
                alert.tag = 10000;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert show];
                });
            }
        }
    }];
}

- (NSString *)getCurrentVersionCode {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (NSString *)getCurrentVersionName {
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (version == nil) {
        version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    }
    return version;
}

- (NSDictionary *)getServerVersionCode:(NSString *)url {
    
    @try {
        NSError *error = nil;
        
        //加载一个NSURL对象
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
        //将请求的url数据放到NSData对象中
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        
        return resultDic;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10000) {
        if (buttonIndex == 1) {
            NSURL *url = [NSURL URLWithString:ipaPath];
            [[UIApplication sharedApplication]openURL:url];
        }
    }
}


@end