//
//  HIVENotificationService.h
//  HIVEExtensions
//
//  Created by KyuJin Kim on 2016. 12. 23..
//  Copyright © 2016년 KyuJin Kim. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>

FOUNDATION_EXPORT NSString * const kHIVENotificationUserInfoAttachmentKey;

@interface HIVENotificationService : NSObject

+ (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent *))contentHandler;
+ (void)serviceExtensionTimeWillExpire;
@end
