//
//  ViewController.m
//  TestAddressBook
//
//  Created by mesird on 17/01/2017.
//  Copyright © 2017 mesird. All rights reserved.
//

#import "ViewController.h"

#import "MSDAddressBook.h"

#import "MSDContact.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *addContactButton;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mobile;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _name = @"Jack";
    _mobile = @"18888888888";
}

- (IBAction)pressOnAddContactButton:(UIButton *)sender {
    
    MSDAddressBookAccessStatus status = [MSDAddressBook addressBookAccessStatus];
    if (status == MSDAddressBookAccessStatusDenied) {
        _infoLabel.text = @"denied by user";
        return;
    }
    
    void (^finishAction)(void) = ^(void) {
        MSDContact *contact = [[MSDContact alloc] init];
        contact.firstName = _name;
        contact.mobile = _mobile;
        NSError *error = nil;
        [[MSDAddressBook sharedAddressBook] addContact:contact error:&error];
        if (!error) {
            _infoLabel.text = @"add to address book successfully!";
        } else {
            _infoLabel.text = [NSString stringWithFormat:@"fail to add contact, reason : %@", error.localizedDescription];
        }
    };
    
    [[MSDAddressBook sharedAddressBook] requestAccessWithFinishAction:finishAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
