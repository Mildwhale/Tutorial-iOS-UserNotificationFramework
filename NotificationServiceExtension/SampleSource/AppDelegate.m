//
//  AppDelegate.m
//  usernotification.sample.objc
//
//  Created by KyuJin Kim on 2016. 11. 22..
//  Copyright © 2016년 gcp. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Notification 사용을 요청한다.
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"Notification granted.");
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }];
    
    return YES;
}

#pragma mark - Receive remote notification delegates
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    NSLog(@"[%s] %@", __PRETTY_FUNCTION__, response.notification.request.content);
    
    completionHandler();
}

#pragma mark - Register remote notification delegates
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *tokenString = [[deviceToken.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"[%s] %@", __PRETTY_FUNCTION__, tokenString);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"[%s] %@", __PRETTY_FUNCTION__, error.localizedDescription);
}
@end
