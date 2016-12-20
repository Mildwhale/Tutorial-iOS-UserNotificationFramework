//
//  PickerViewController.h
//  usernotification.sample.objc
//
//  Created by KyuJin Kim on 2016. 12. 1..
//  Copyright © 2016년 gcp. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PickerViewControllerDelegate;

@interface PickerViewController : UIViewController

@property (nonatomic, weak) id<PickerViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;

@property (nonatomic) NSUInteger itemType;
@property (nonatomic, strong) NSArray *pickerItems;
@end

@protocol PickerViewControllerDelegate <NSObject>
- (void)picker:(PickerViewController *)viewController closeWith:(NSUInteger)selectedIndex;
@end
