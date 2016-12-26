//
//  HIVENotificationService.m
//  HIVEExtensions
//
//  Created by KyuJin Kim on 2016. 12. 23..
//  Copyright © 2016년 KyuJin Kim. All rights reserved.
//

#import "HIVENotificationService.h"

NSString * const kHIVENotificationUserInfoAttachmentKey = @"attachment-media";

@interface HIVENotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation HIVENotificationService
+ (instancetype)sharedInstance
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

+ (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent *))contentHandler
{
    [[HIVENotificationService sharedInstance] didReceiveNotificationRequest:request withContentHandler:contentHandler];
}

+ (void)serviceExtensionTimeWillExpire
{
    [[HIVENotificationService sharedInstance] serviceExtensionTimeWillExpire];
}

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler
{
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSDictionary *userInfo = request.content.userInfo; // Push Payload의 사용자 정의 데이터.
    NSURL *mediaURL = [NSURL URLWithString:userInfo[kHIVENotificationUserInfoAttachmentKey]];
    
    NSLog(@"[%s] Received UserInfo : %@", __PRETTY_FUNCTION__, userInfo);
    
    // 미디어 파일 다운로드 시작.
    [[[NSURLSession sharedSession] downloadTaskWithURL:mediaURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || !location) {
            // 다운로드 실패.
            NSLog(@"code : %ld, description : %@", error.code, error.localizedDescription);
        } else {
            NSString *tmpDirectory = [NSString stringWithFormat:@"file://%@", NSTemporaryDirectory()];
            NSURL *newFileURL = [NSURL URLWithString:[tmpDirectory stringByAppendingString:mediaURL.lastPathComponent]];
            
            if (!newFileURL) {
                // URL 생성에 실패했을 경우, 파일명을 변경하여 다시 시도한다.
                NSString *timeStamp = [NSString stringWithFormat:@"%lf", [NSDate date].timeIntervalSince1970];
                newFileURL = [NSURL URLWithString:[tmpDirectory stringByAppendingString:[location.lastPathComponent stringByReplacingOccurrencesOfString:timeStamp withString:mediaURL.pathExtension]]];
            }
            
            NSError *fileMoveError;
            
            if ([[NSFileManager defaultManager] moveItemAtURL:location toURL:newFileURL error:&fileMoveError]) {
                // 다운로드 완료된 미디어의 URL로, Attachment 객체를 생성한다.
                UNNotificationAttachment *attachement = [UNNotificationAttachment attachmentWithIdentifier:@"hive-media" URL:newFileURL options:nil error:nil];
                
                // Attachment 객체를 NotificationRequest에 추가한다.
                self.bestAttemptContent.attachments = @[attachement];
            } else {
                // 미디어 파일 이동 실패.
                NSLog(@"code : %ld, description : %@", fileMoveError.code, fileMoveError.localizedDescription);
            }
        }
        
        self.contentHandler(self.bestAttemptContent);
    }] resume];
    
}

- (void)serviceExtensionTimeWillExpire
{
    self.contentHandler(self.bestAttemptContent);
}
@end
