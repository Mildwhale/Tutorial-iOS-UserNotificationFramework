//
//  NotificationService.m
//  NotificationServiceExtension
//
//  Created by KyuJin Kim on 2016. 12. 23..
//  Copyright © 2016년 KyuJin Kim. All rights reserved.
//

#import "NotificationService.h"
#import <HIVEExtensions/HIVEExtensions.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    [HIVENotificationService didReceiveNotificationRequest:request withContentHandler:contentHandler];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    [HIVENotificationService serviceExtensionTimeWillExpire];
}

@end
