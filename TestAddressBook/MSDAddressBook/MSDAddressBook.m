//
//  MSDAddressBook.m
//  TestAddressBook
//
//  Created by mesird on 17/01/2017.
//  Copyright © 2017 mesird. All rights reserved.
//

#import "MSDAddressBook.h"

#import <AddressBook/AddressBook.h>

#import "MSDContact.h"

@interface MSDAddressBook ()

@property (nonatomic, assign) ABAddressBookRef addressBook;

@end

@implementation MSDAddressBook

static NSString *const kErrorDomain = @"com.ErrorDomain";

static const NSInteger kErrorCodeNotAllowed  = 9001;
static const NSInteger kErrorCodeMobileEmpty = 9002;

- (ABAddressBookRef)addressBook {
    
    if (_addressBook == NULL) {
        _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    }
    return _addressBook;
}

/** singleton*/
+ (instancetype)sharedAddressBook {
    
    static MSDAddressBook *addressBook = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        addressBook = [[self alloc] init];
    });
    return addressBook;
}

/** current address book access status*/
+ (MSDAddressBookAccessStatus)addressBookAccessStatus {
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusNotDetermined) {
        return MSDAddressBookAccessStatusNotDetermined;
    } else if (status == kABAuthorizationStatusDenied) {
        return MSDAddressBookAccessStatusDenied;
    } else if (status == kABAuthorizationStatusAuthorized) {
        return MSDAddressBookAccessStatusAllowed;
    } else {
        return MSDAddressBookAccessStatusDenied;
    }
}

/** add a contact to address book*/
- (void)addContact:(MSDContact *)contact error:(NSError **)error {
    NSAssert(contact, @"The contact for adding cannot be nil");
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status != kABAuthorizationStatusAuthorized) {
        (*error) = [NSError errorWithDomain:kErrorDomain code:kErrorCodeNotAllowed userInfo:@{NSLocalizedDescriptionKey:@"Addressbook access is not permitted"}];
        return;
    }
    
    if (contact.mobile.length == 0) {
        (*error) = [NSError errorWithDomain:kErrorDomain code:kErrorCodeMobileEmpty userInfo:@{NSLocalizedDescriptionKey:@"Mobile cannot be empty"}];
        return;
    }
    
    ABRecordRef person = ABPersonCreate();
    CFErrorRef cfError = NULL;
    if (contact.firstName.length) {
        ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFStringRef)(contact.firstName), &cfError);
    }
    if (contact.lastName.length) {
        ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFStringRef)(contact.firstName), &cfError);
    }
    
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFStringRef)(contact.mobile), kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(person, kABPersonPhoneProperty, multiPhone, &cfError);
    CFRelease(multiPhone);
    
    ABAddressBookAddRecord(self.addressBook, person, &cfError);
    ABAddressBookSave(self.addressBook, &cfError);
    
    CFRelease(person);
}

/** return all contacts*/
- (NSArray *)allContacts {
    
    // TODO : someone please implement this if it's needed
    return nil;
}

/** execute finish action after gainning address book access*/
- (void)requestAccessWithFinishAction:(FinishAction)finishAction {
    
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            finishAction();
        }
    });
}

@end
