//
//  MSDAddressBook.h
//  TestAddressBook
//
//  Created by mesird on 17/01/2017.
//  Copyright © 2017 mesird. All rights reserved.
//
//  This is a simple address book wrapper for AddressBook.framework
//
//
//

#import <Foundation/Foundation.h>

typedef void (^FinishAction)();

typedef NS_ENUM(NSInteger, MSDAddressBookAccessStatus) {
    MSDAddressBookAccessStatusAllowed,          // allowed by user
    MSDAddressBookAccessStatusDenied,           // denied by user
    MSDAddressBookAccessStatusNotDetermined     // haven't made choice yet
};

@class MSDContact;
@interface MSDAddressBook : NSObject

/** current address book access status*/
+ (MSDAddressBookAccessStatus)addressBookAccessStatus;


/** singleton*/
+ (instancetype)sharedAddressBook;

/** add a contact to address book*/
- (void)addContact:(MSDContact *)contact error:(NSError **)error;

/** return all contacts*/
- (NSArray *)allContacts;

/** execute finish action after gainning address book access*/
- (void)requestAccessWithFinishAction:(FinishAction)finishAction;

@end
