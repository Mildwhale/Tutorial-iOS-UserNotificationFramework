//
//  PickerViewController.m
//  usernotification.sample.objc
//
//  Created by KyuJin Kim on 2016. 12. 1..
//  Copyright © 2016년 gcp. All rights reserved.
//

#import "PickerViewController.h"

@interface PickerViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic) NSUInteger selectedIndex;
@end

@implementation PickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exit:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(picker:closeWith:)]) {
        [self.delegate picker:self closeWith:self.selectedIndex];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerItems.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickerItems[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"[%s] %@", __PRETTY_FUNCTION__, self.pickerItems[row]);
    self.selectedIndex = row;
}
@end
