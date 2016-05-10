//
//  MailBox.m
//  ImapClient
//
//  Created by Trần Quang Tuấn on 05/05/2016.
//  Copyright © 2016 Alleria. All rights reserved.
//

#import "MailBox.h"

@implementation MailBox

- (instancetype)init {
    self = [super init];
    if (self) {
        _fetchedMessages = [NSMutableArray new];
    }
    return self;
}

@end
