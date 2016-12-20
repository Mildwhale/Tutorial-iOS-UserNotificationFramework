//
//  NotificationService.m
//  NotificationServiceExtension
//
//  Created by KyuJin Kim on 2016. 12. 1..
//  Copyright © 2016년 gcp. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSDictionary *userInfo = request.content.userInfo; // Push Payload의 사용자 정의 데이터.
    NSURL *mediaURL = [NSURL URLWithString:userInfo[@"attachment-media"]];
    
    NSLog(@"[%s] Received UserInfo : %@", __PRETTY_FUNCTION__, userInfo);
    
    // 미디어 파일 다운로드 시작.
    [[[NSURLSession sharedSession] downloadTaskWithURL:mediaURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || !location) {
            // 다운로드 실패.
            NSLog(@"code : %ld, description : %@", error.code, error.localizedDescription);
            self.contentHandler(self.bestAttemptContent);
            return ;
        }
        
        NSString *tmpDirectory = [NSString stringWithFormat:@"file://%@", NSTemporaryDirectory()];
        NSURL *newFileURL = [NSURL URLWithString:[tmpDirectory stringByAppendingString:mediaURL.lastPathComponent]];
        
        if (!newFileURL) {
            // URL 생성에 실패했을 경우, 파일명을 변경하여 다시 시도한다.
            newFileURL = [NSURL URLWithString:[tmpDirectory stringByAppendingString:[location.lastPathComponent stringByReplacingOccurrencesOfString:@"tmp" withString:mediaURL.pathExtension]]];
        }
        
        if (!newFileURL) {
            // 최종적으로 URL이 없을 경우, 미디어를 노출하지 않는다.
            self.contentHandler(self.bestAttemptContent);
            return ;
        }
        
        NSError *fileError;
        
        if ([[NSFileManager defaultManager] moveItemAtURL:location toURL:newFileURL error:&fileError]) {
            // 다운로드 완료된 미디어의 URL로, Attachment 객체를 생성한다.
            UNNotificationAttachment *attachement = [UNNotificationAttachment attachmentWithIdentifier:@"media" URL:newFileURL options:nil error:nil];
            
            // Attachment 객체를 NotificationRequest에 추가한다.
            self.bestAttemptContent.attachments = @[attachement];
        } else {
            // 미디어 파일 이동 실패.
            NSLog(@"code : %ld, description : %@", fileError.code, fileError.localizedDescription);
        }
        
        self.contentHandler(self.bestAttemptContent);
    }] resume];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
