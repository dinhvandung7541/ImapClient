//
//  MailBoxViewControllerTableViewController.m
//  ImapClient
//
//  Created by Trần Quang Tuấn on 04/05/2016.
//  Copyright © 2016 Alleria. All rights reserved.
//

#import "MailBoxViewController.h"
#import "Imap.h"
#import "MailBox.h"
#import "Utilities.h"

static MailBoxViewController *mailBoxViewController;

@interface MailBoxViewController ()

@end

@implementation MailBoxViewController {
    MailBox *_selectedMailBox;
}

+ (MailBoxViewController *)mailBoxViewController {
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            mailBoxViewController = [[MailBoxViewController alloc] init];
        });
    }
    
    return mailBoxViewController;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _selectedMailBox = [[Imap imap] selectedMailBox];
    self.navigationItem.title = _selectedMailBox.name;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 75;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_selectedMailBox.fetchedMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"mCell"];
    }
    Message *message = [_selectedMailBox.fetchedMessages objectAtIndex:indexPath.row];
    cell.textLabel.text = [Utilities decodeHeader:[message subject]];
    cell.detailTextLabel.text = [Utilities decodeHeader:[message from]];
    return cell;
}

@end
