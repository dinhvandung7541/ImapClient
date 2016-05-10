//
//  MailBoxListViewController.h
//  ImapClient
//
//  Created by Trần Quang Tuấn on 04/05/2016.
//  Copyright © 2016 Alleria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailBoxListViewController : UITableViewController <UITableViewDelegate , UITableViewDataSource>

+ (MailBoxListViewController *)mailBoxListViewController;

@end
