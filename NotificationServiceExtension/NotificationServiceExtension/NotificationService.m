//
//  NotificationService.m
//  NotificationServiceExtension
//
//  Created by KyuJin Kim on 2016. 12. 1..
//  Copyright © 2016년 gcp. All rights reserved.
//

#import "NotificationService.h"
#import <HIVEExtensions/HIVEExtensions.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler
{
    [HIVENotificationService didReceiveNotificationRequest:request withContentHandler:contentHandler];
}

- (void)serviceExtensionTimeWillExpire
{
    [HIVENotificationService serviceExtensionTimeWillExpire];
}

@end
