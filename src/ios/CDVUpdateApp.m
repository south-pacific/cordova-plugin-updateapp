#import "CDVUpdateApp.h"
#import <Cordova/CDVPluginResult.h>

@implementation CDVUpdateApp

NSString *ipaPath;

- (void)getCurrentVersion:(CDVInvokedUrlCommand*)command
{

    NSString* callbackId = command.callbackId;
    NSString* version = [self getCurrentVersionCode];

    CDVPluginResult* pluginResult = nil;
    NSString* javaScript = nil;

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:version];
    javaScript = [pluginResult toSuccessCallbackString:callbackId];

    [self writeJavascript:javaScript];
}

- (void)getServerVersion:(CDVInvokedUrlCommand*)command
{
    
    NSString *URL = [command argumentAtIndex:0];
    
    NSDictionary *resultDic = [self getServerVersionCode:URL];
    NSString *lastVersion = [resultDic objectForKey:@"verName"];
        
    NSString* callbackId = command.callbackId;
        
    CDVPluginResult* pluginResult = nil;
    NSString* javaScript = nil;
        
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:lastVersion];
    javaScript = [pluginResult toSuccessCallbackString:callbackId];
        
    [self writeJavascript:javaScript];
}

- (void)checkAndUpdate:(CDVInvokedUrlCommand*)command
{
    NSString *URL = [command argumentAtIndex:0];
    NSDictionary *resultDic = [self getServerVersionCode:URL];
    NSString *lastVersion = [resultDic objectForKey:@"verName"];
    ipaPath = [resultDic objectForKey:@"ipaPath"];
    
    if (![[self getCurrentVersionCode] isEqualToString:lastVersion]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"有新的版本，是否前往更新？" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
        alert.tag = 10000;
        [alert show];
    }
}

- (NSString *)getCurrentVersionCode {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (NSDictionary *)getServerVersionCode:(NSString *)url {
    NSError *error = nil;
    
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    
    return resultDic;
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