//
//  ViewController.m
//  usernotification.sample.objc
//
//  Created by KyuJin Kim on 2016. 11. 22..
//  Copyright © 2016년 gcp. All rights reserved.
//

#import "ViewController.h"
#import "PickerViewController.h"
#import <UserNotifications/UserNotifications.h>

typedef NS_ENUM(NSUInteger, TableViewSection) {
    TableViewSectionSetting,
    TableViewSectionRegister
};

typedef NS_ENUM(NSUInteger, NotificationSetting) {
    NotificationSettingTitle,
    NotificationSettingSubtitle,
    NotificationSettingBody,
    NotificationSettingInterval,
    NotificationSettingAttachment
};

typedef NS_ENUM(NSUInteger, AttachmentType) {
    AttachmentTypeNONE,
    AttachmentTypeJPG,
    AttachmentTypeGIF,
    AttachmentTypeMP4,
    AttachmentTypeMP3
};

@interface ViewController () <PickerViewControllerDelegate>

@property (nonatomic, strong) NSString *notificationTitle;
@property (nonatomic, strong) NSString *notificationSubTitle;
@property (nonatomic, strong) NSString *notificationBody;

@property (nonatomic, strong) NSArray *intervals;
@property (nonatomic, strong) NSArray *attachmentTypes;

@property (nonatomic) NSTimeInterval interval;
@property (nonatomic) AttachmentType attachmentType;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self addObservers];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    self.interval = 5.0;
    self.attachmentType = AttachmentTypeNONE;
    
    self.notificationTitle = @"Default Title";
    self.notificationSubTitle = @"Default Subtitle";
    self.notificationBody = @"Default Body";
    
    self.intervals = @[@"5", @"10", @"20", @"30", @"40", @"50", @"60"];
    self.attachmentTypes = @[@"NONE", @"JPG", @"GIF", @"MP4", @"MP3"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addObservers
{
    [self addObserver:self forKeyPath:@"notificationTitle" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"notificationSubTitle" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"notificationBody" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"interval" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"attachmentType" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservers
{
    [self removeObserver:self forKeyPath:@"notificationTitle"];
    [self removeObserver:self forKeyPath:@"notificationSubTitle"];
    [self removeObserver:self forKeyPath:@"notificationBody"];
    [self removeObserver:self forKeyPath:@"interval"];
    [self removeObserver:self forKeyPath:@"attachmentType"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"notificationTitle"]) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:NotificationSettingTitle inSection:TableViewSectionSetting]].detailTextLabel.text = change[NSKeyValueChangeNewKey];
    } else if ([keyPath isEqualToString:@"notificationSubTitle"]) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:NotificationSettingSubtitle inSection:TableViewSectionSetting]].detailTextLabel.text = change[NSKeyValueChangeNewKey];
    } else if ([keyPath isEqualToString:@"notificationBody"]) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:NotificationSettingBody inSection:TableViewSectionSetting]].detailTextLabel.text = change[NSKeyValueChangeNewKey];
    } else if ([keyPath isEqualToString:@"interval"]) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:NotificationSettingInterval inSection:TableViewSectionSetting]].detailTextLabel.text = [change[NSKeyValueChangeNewKey] stringValue];
    } else if ([keyPath isEqualToString:@"attachmentType"]) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:NotificationSettingAttachment inSection:TableViewSectionSetting]].detailTextLabel.text = self.attachmentTypes[[change[NSKeyValueChangeNewKey] integerValue]];
    }
}

#pragma mark - Button Event
- (void)registerLocalNotification
{
    // iOS 10 이상에서 Local Notification 등록.
    UNMutableNotificationContent *mutableContent = [[UNMutableNotificationContent alloc] init];
    
    mutableContent.title = self.notificationTitle;
    mutableContent.subtitle = self.notificationSubTitle;
    mutableContent.body = self.notificationBody;

    if (self.attachmentType != AttachmentTypeNONE) {
        NSString *filePath = @"file://";
        
        switch (self.attachmentType) {
            case AttachmentTypeJPG:
                filePath = [filePath stringByAppendingString:[[NSBundle mainBundle] pathForResource:@"jpgsample" ofType:@"jpg"]];
                break;
            case AttachmentTypeMP3:
                filePath = [filePath stringByAppendingString:[[NSBundle mainBundle] pathForResource:@"mp3sample" ofType:@"mp3"]];
                break;
            case AttachmentTypeMP4:
                filePath = [filePath stringByAppendingString:[[NSBundle mainBundle] pathForResource:@"mp4sample" ofType:@"mp4"]];
                break;
            case AttachmentTypeGIF:
                filePath = [filePath stringByAppendingString:[[NSBundle mainBundle] pathForResource:@"gifsample" ofType:@"gif"]];
                break;
            default:
                break;
        }
        
        NSURL *fileURL = [NSURL URLWithString:filePath];
        
        if (fileURL) {
            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"identifier" URL:fileURL options:nil error:nil];
            
            if (attachment) {
                mutableContent.attachments = @[attachment];
            }
        }
    }
    
    UNNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:self.interval repeats:NO];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:[UNNotificationRequest requestWithIdentifier:@"local"
                                                                                                                      content:mutableContent
                                                                                                                      trigger:trigger] withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"Register : %@", mutableContent);
    }];
}

- (void)presentDialogForSetting:(NotificationSetting)type
{
    switch (type) {
        case NotificationSettingTitle:
        case NotificationSettingSubtitle:
        case NotificationSettingBody:
            [self presentTextInputDialog:type];
            break;
            
        case NotificationSettingInterval:
        case NotificationSettingAttachment:
            [self presentPickerDialog:type];
            break;
            
        default:
            break;
    }
}

- (void)presentTextInputDialog:(NotificationSetting)type
{
    NSString *alertMessage = nil;
    
    switch (type) {
        case NotificationSettingTitle:
            alertMessage = @"Input Notification Title";
            break;
            
        case NotificationSettingSubtitle:
            alertMessage = @"Input Notification Subtitle";
            break;
            
        case NotificationSettingBody:
            alertMessage = @"Input Notification Body";
            break;
            
        default:
            break;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [alertController dismissViewControllerAnimated:YES completion:nil];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Confirm"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          switch (type) {
                                                              case NotificationSettingTitle:
                                                                  self.notificationTitle = alertController.textFields[0].text;
                                                                  break;
                                                                  
                                                              case NotificationSettingSubtitle:
                                                                  self.notificationSubTitle = alertController.textFields[0].text;
                                                                  break;
                                                                  
                                                              case NotificationSettingBody:
                                                                  self.notificationBody = alertController.textFields[0].text;
                                                                  break;
                                                                  
                                                              default:
                                                                  break;
                                                          }
                                                          
                                                          [alertController dismissViewControllerAnimated:YES completion:nil];
                                                      }]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        switch (type) {
            case NotificationSettingTitle:
                textField.text = self.notificationTitle;
                break;
                
            case NotificationSettingSubtitle:
                textField.text = self.notificationSubTitle;
                break;
                
            case NotificationSettingBody:
                textField.text = self.notificationBody;
                break;
                
            default:
                break;
        }
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)presentPickerDialog:(NotificationSetting)type
{
    PickerViewController *pickerVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PickerView"];
    pickerVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    pickerVC.delegate = self;
 
    if (type == NotificationSettingInterval) {
        pickerVC.itemType = NotificationSettingInterval;
        pickerVC.pickerItems = self.intervals;
    } else if (type == NotificationSettingAttachment) {
        pickerVC.itemType = NotificationSettingAttachment;
        pickerVC.pickerItems = self.attachmentTypes;
    }
    
    [self.navigationController presentViewController:pickerVC animated:NO completion:nil];
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == TableViewSectionSetting) {
        [self presentDialogForSetting:indexPath.row];
    } else {
        [self registerLocalNotification];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 10.0) {
        // Can't supported UNNotification framework.
        if (indexPath.section == TableViewSectionSetting) {
            if (indexPath.row == NotificationSettingSubtitle || indexPath.row == NotificationSettingAttachment) {
                return 0.f;
            }
        }
    }
    
    return tableView.rowHeight;
}

#pragma mark - PickerViewController Delegate
- (void)picker:(PickerViewController *)viewController closeWith:(NSUInteger)selectedIndex
{
    NotificationSetting settingType = viewController.itemType;
    
    if (settingType == NotificationSettingInterval) {
        self.interval = [self.intervals[selectedIndex] doubleValue];
    } else {
        self.attachmentType = selectedIndex;
    }
}
@end
