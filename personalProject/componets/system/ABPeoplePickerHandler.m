//
//  ABPeoplePickerHandler.m
//  SuningEBuy
//
//  Created by wangbin on 16/1/16.
//  Copyright © 2016年 苏宁易购. All rights reserved.
//

#import "ABPeoplePickerHandler.h"
#import "UIViewController+CMToast.h"
#import <AddressBook/AddressBook.h>
#import "CMCommonHeader.h"
#import <AddressBookUI/AddressBookUI.h>

@interface ABPeoplePickerHandler ()<ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, copy) ABPeoplePickerCancelBlock cancelBlock;
@property (nonatomic, copy) ABPeoplePickerDidPickPersonBlock didPickPersonBlock;

@end

@implementation ABPeoplePickerHandler

static ABPeoplePickerHandler *handler = nil;

/**
 *  选择通讯录
 *
 *  @param controller         controller
 *  @param cancelBlock        取消block
 *  @param didPickPersonBlock 选中block
 */
+ (void)pickInController:(CMCommomViewController *)controller
             cancelBlock:(ABPeoplePickerCancelBlock)cancelBlock
      didPickPersonBlock:(ABPeoplePickerDidPickPersonBlock)didPickPersonBlock {
    @synchronized(handler) {
        if (handler == nil) {
            handler = [[ABPeoplePickerHandler alloc] init];
            handler.cancelBlock = cancelBlock;
            handler.didPickPersonBlock = didPickPersonBlock;
            [handler pickInController:controller];
        }
    }
}

- (void)pickInController:(CMCommomViewController *)controller {
    __weak typeof(self) wself = self;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself goToABPeoplePickerView:controller];
            });
            dispatch_semaphore_signal(sema);
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ABAddressBookGetAuthorizationStatus()!= kABAuthorizationStatusAuthorized ) {
                    [controller toast:@"请打开通讯录权限"];
                }
            });
            dispatch_semaphore_signal(sema);
        }
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
#if !OS_OBJECT_USE_OBJC
    if (sema) dispatch_release(sema);
#endif
    sema = NULL;
}

/**
 *  显示通讯录
 *
 *  @param controller
 */
- (void)goToABPeoplePickerView:(CMCommomViewController *)controller {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty],nil];
    picker.displayedProperties = displayedItems;
    [controller presentViewController:picker animated:YES completion:nil];
}

#pragma mark ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    
    [self endHandler:peoplePicker];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    [self didSelectPerson:person property:property identifier:identifier];
    
    [self endHandler:peoplePicker];
    
    return NO;
}

#ifdef __IPHONE_8_0
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker
                         didSelectPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    [self didSelectPerson:person property:property identifier:identifier];
    
    [self endHandler:peoplePicker];
}
#endif

/**
 *  选中了通讯录人员
 *
 *  @param person     人员
 *  @param property   属性
 *  @param identifier 标识
 */
- (void)didSelectPerson:(ABRecordRef)person
               property:(ABPropertyID)property
             identifier:(ABMultiValueIdentifier)identifier {
    ABMultiValueRef phoneProperty = ABRecordCopyValue(person,property);
    CFIndex index= ABMultiValueGetIndexForIdentifier(phoneProperty,identifier);
    NSString *phone = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneProperty,index));
    if (phoneProperty!=NULL) {
        CFRelease(phoneProperty);
    }
    
    NSString *phoneStr = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@")" withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (phoneStr.length==12&&[[phoneStr substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"1"] ) {
        phoneStr = [phoneStr substringFromIndex:1];
    }
    TT_RELEASE_SAFELY(phone);
        NSString *name = (NSString *)CFBridgingRelease(ABRecordCopyCompositeName(person));
    if (self.didPickPersonBlock) {
        self.didPickPersonBlock(name, phoneStr);
    }
}

/**
 *  结束处理
 *
 *  @param peoplePicker
 */
- (void)endHandler:(ABPeoplePickerNavigationController *)peoplePicker {
    [peoplePicker dismissViewControllerAnimated:YES completion:^{
        handler = nil;
    }];
}

@end
