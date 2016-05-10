//
//  Ultilities.h
//  ImapClient
//
//  Created by Trần Quang Tuấn on 04/05/2016.
//  Copyright © 2016 Alleria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+ (NSString *)decodeMailBoxName:(NSString *)src;
+ (NSString *)decodeHeader:(NSString *)src;
+ (NSData *)decodeQuotedPrintable:(NSString *)s;

@end
