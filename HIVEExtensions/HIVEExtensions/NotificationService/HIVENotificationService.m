//
//  HIVENotificationService.m
//  HIVEExtensions
//
//  Created by KyuJin Kim on 2016. 12. 23..
//  Copyright © 2016년 KyuJin Kim. All rights reserved.
//

#import "HIVENotificationService.h"

@implementation HIVENotificationService
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)serviceExtensionTimeWillExpire
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
@end
