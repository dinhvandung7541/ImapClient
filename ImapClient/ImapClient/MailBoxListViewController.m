//
//  MailBoxListViewController.m
//  ImapClient
//
//  Created by Trần Quang Tuấn on 04/05/2016.
//  Copyright © 2016 Alleria. All rights reserved.
//

#import "MailBoxListViewController.h"
#import "MailBoxViewController.h"
#import "Imap.h"
#import "Utilities.h"

static MailBoxListViewController *mailBoxListViewController;

@interface MailBoxListViewController ()

@end

@implementation MailBoxListViewController {
    NSIndexPath *_currentIndexPath;
}

+ (MailBoxListViewController *)mailBoxListViewController {
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            mailBoxListViewController = [[MailBoxListViewController alloc] init];
        });
    }
    
    return mailBoxListViewController;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.title = @"MailBox";
    self.tableView.rowHeight = 75;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectSuccess) name:@"select success" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchSuccess) name:@"fetch success" object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[Imap imap] mailBoxList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    NSString *prefixName = [[[[Imap imap] mailBoxList] objectAtIndex:indexPath.row] name];
    cell.textLabel.text = [Utilities decodeMailBoxName:prefixName];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _currentIndexPath = indexPath;
    MailBox *mailBox = [[[Imap imap] mailBoxList] objectAtIndex:indexPath.row];
    [[Imap imap] commandSelect:mailBox.name];
}

- (void)selectSuccess {
    [[Imap imap] setSelectedMailBox:[[[Imap imap] mailBoxList] objectAtIndex:_currentIndexPath.row]];
    [[Imap imap] readSelectedMailBox];
    MailBox *selectedMailBox = [[Imap imap] selectedMailBox];
    int min = (selectedMailBox.messagesCount - 10 > 0)? (selectedMailBox.messagesCount - 10):1;
    int max = selectedMailBox.messagesCount;
    // not complete , just fetch 10 first messages
    [[Imap imap] commandFetch:[NSString stringWithFormat:@"%d:%d",min,max] and:@"(body[header.fields (from subject date)])"];
}

- (void)fetchSuccess {
    [[Imap imap] readMessagesList];
    [[[MailBoxViewController mailBoxViewController] tableView] reloadData];
    [self.navigationController pushViewController:[MailBoxViewController mailBoxViewController] animated:YES];
}

@end
