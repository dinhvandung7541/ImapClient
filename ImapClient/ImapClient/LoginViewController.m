 //
//  LoginViewController.m
//  ImapClient
//
//  Created by Trần Quang Tuấn on 04/05/2016.
//  Copyright © 2016 Alleria. All rights reserved.
//

#import "LoginViewController.h"
#import "MailBoxListViewController.h"
#import "Imap.h"
#import "Utilities.h"

static LoginViewController *loginViewController;

@interface LoginViewController ()

@end

@implementation LoginViewController {
}

+ (LoginViewController *)loginViewController {
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            loginViewController = [[LoginViewController alloc] init];
        });
    }
    
    return loginViewController;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Login";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucess) name:@"login success" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listSucess) name:@"list success" object:nil];
}

- (IBAction)loginButtonPressed:(id)sender {
    [[Imap imap] openConnection];
    [[Imap imap] commandLogin:_userNameTextField.text and:_passwordTextField.text];
}

- (void)loginSucess {
    [[Imap imap] commandList];
}

- (void)listSucess {
    [[Imap imap] readMailBoxList];
    [[[MailBoxListViewController mailBoxListViewController] tableView] reloadData];
    [self.navigationController pushViewController:[MailBoxListViewController mailBoxListViewController] animated:YES];
}

@end
