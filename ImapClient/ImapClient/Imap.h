//
//  Imap.h
//  ImapClient
//
//  Created by Trần Quang Tuấn on 04/05/2016.
//  Copyright © 2016 Alleria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sys/socket.h"
#import "netinet/in.h"
#import "arpa/inet.h"
#import "MailBox.h"
#import "Message.h"
#include "MailBoxListViewController.h"
#include "MailBoxViewController.h"

@interface Imap : NSObject <NSStreamDelegate>

@property MailBox *selectedMailBox;
@property NSMutableArray *mailBoxList;
@property NSMutableString *response;
@property NSString *currentCommand;
@property int commandCount;

+ (Imap *)imap;
- (void)readMailBoxList;
- (void)readMessagesList;
- (void)readSelectedMailBox;

- (void)openConnection;
- (void)commandLogin:(NSString *)username and:(NSString *)password;
- (void)commandList;
- (void)commandSelect:(NSString *)mailBox;
- (void)commandFetch:(NSString *)sequence and:(NSString *)fields;

@end
