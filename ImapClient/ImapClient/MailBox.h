//
//  MailBox.h
//  ImapClient
//
//  Created by Trần Quang Tuấn on 05/05/2016.
//  Copyright © 2016 Alleria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MailBox : NSObject

@property NSString *name;
@property int messagesCount;
@property NSMutableArray *fetchedMessages;

@end
