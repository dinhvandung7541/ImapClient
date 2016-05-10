//
//  Imap.m
//  ImapClient
//
//  Created by Trần Quang Tuấn on 04/05/2016.
//  Copyright © 2016 Alleria. All rights reserved.
//

#import "Imap.h"

#define PORT 993
#define SERVER_ADDRESS @"imap.gmail.com"
#define READ_SIZE 2048
#define NUMBER_MESSAGE_FETCHED 10

static Imap *imap;

@implementation Imap {
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
}

+ (Imap *)imap {
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            imap = [[Imap alloc] init];
        });
    }
    
    return imap;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _response = [NSMutableString new];
        _mailBoxList = [NSMutableArray new];
        _selectedMailBox = [MailBox new];
    }
    return self;
}

- (void)openConnection {
    // create a Socket and open connect to server
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFSocketRef myipv4cfsock = CFSocketCreate(
                                              kCFAllocatorDefault,
                                              PF_INET,
                                              SOCK_STREAM,
                                              IPPROTO_TCP,
                                              kCFSocketAcceptCallBack, nil, NULL);
    struct sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET;
    sin.sin_port = htons(PORT);
    sin.sin_addr.s_addr= inet_addr([SERVER_ADDRESS cStringUsingEncoding:NSASCIIStringEncoding]);
    CFStreamCreatePairWithSocket ( kCFAllocatorDefault, CFSocketGetNative(myipv4cfsock),&readStream,&writeStream);
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)SERVER_ADDRESS, PORT, &readStream, &writeStream);
    
    if (readStream && writeStream) {
        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        
        _inputStream = (__bridge NSInputStream *)readStream;
        [_inputStream setDelegate:self];
        [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream open];
        
        _outputStream = (__bridge NSOutputStream *)writeStream;
        [_outputStream setDelegate:self];
        [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_outputStream open];
        
        if (PORT == 993) {
            NSDictionary *settings = [[NSDictionary alloc] init];
            CFReadStreamSetProperty((CFReadStreamRef)_inputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
            CFWriteStreamSetProperty((CFWriteStreamRef)_outputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
        }
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    // handle event on input stream and output stream separately
    if (aStream == _inputStream) {
        [self handleInputStreamEvent:eventCode];
    } else if (aStream == _outputStream) {
        [self handleOutputStreamEvent:eventCode];
    }
}

- (void)handleInputStreamEvent:(NSStreamEvent)eventCode {
    // input stream
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable: {
            [self readInputStream];
            break;
        }
        case NSStreamEventOpenCompleted: {
            break;
        }
        case NSStreamEventErrorOccurred: {
            break;
        }
        default:
            break;
    }
}

- (void)handleOutputStreamEvent:(NSStreamEvent)eventCode; {
    //output stream
    switch (eventCode) {
        case NSStreamEventHasSpaceAvailable: {
            break;
        }
        case NSStreamEventOpenCompleted: {
            break;
        }
        case NSStreamEventErrorOccurred: {
            break;
        }
        default:
            break;
    }
}

#pragma mark handle Event

- (void)commandSucess {
    // send a notification each time server response success
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@ success",_currentCommand] object:self];
}

- (void)readInputStream {
    //read data on input stream
    unsigned char buf[READ_SIZE ];
    memset(buf, 0, sizeof(char) * (READ_SIZE ) );
    [_inputStream read:buf maxLength:READ_SIZE];
    NSString* data = [NSString stringWithUTF8String:(char *)buf];
    [_response appendString:data];
    NSLog(@"%@",_response);
    
    NSArray *subString = [_response componentsSeparatedByString:@" "];
    if ([[subString objectAtIndex:subString.count - 1] isEqualToString:@"Success\r\n"]||[[subString objectAtIndex:subString.count - 1] isEqualToString:@"(Success)\r\n"]) {
        [self commandSucess];
    }
}

- (void)readMailBoxList {
    //analyze response of LIST command and add data to mailBoxList
    _mailBoxList = [NSMutableArray new];
    NSMutableArray *subString = (NSMutableArray *)[_response componentsSeparatedByString:@"*"];
    [subString removeObjectAtIndex:0];
    for (NSString *string in subString) {
        NSArray *subString2 = [string componentsSeparatedByString:@"\""];
        MailBox *thisMailBox = [MailBox new];
        thisMailBox.name = subString2[3];
        [_mailBoxList addObject:thisMailBox];
    }
}

- (void)readMessagesList {
    //analyze response of FETCH command and add data to selectedMailBox.fetchedMessages
    NSMutableArray *subString = (NSMutableArray *)[_response componentsSeparatedByString:@"*"];
    [subString removeObjectAtIndex:0];
    _selectedMailBox.fetchedMessages = [NSMutableArray new];
    for (NSString *string in subString) {
        Message *message = [Message new];
        NSMutableArray *subString2 = (NSMutableArray *)[string componentsSeparatedByString:@"\r\n"];
        for (NSString *string in subString2) {
            NSMutableArray *subString3 = (NSMutableArray *)[string componentsSeparatedByString:@":"];
            if ([subString3[0] isEqualToString:@"Date"]) {
                message.date = subString3[1];
            }
            else if ([subString3[0] isEqualToString:@"From"]) {
                message.from = subString3[1];
            }
            else if ([subString3[0] isEqualToString:@"Subject"]) {
                message.subject = subString3[1];
            }
        }
        [_selectedMailBox.fetchedMessages insertObject:message atIndex:0];
    }
}

- (void)readSelectedMailBox {
    // analyze response of SELECT command and add data to selectedMailBox
    NSMutableArray *subString = (NSMutableArray *)[_response componentsSeparatedByString:@"*"];
    NSMutableArray *subString2 = (NSMutableArray *)[subString[5] componentsSeparatedByString:@" "];
    _selectedMailBox.messagesCount = (int)[subString2[1] integerValue];
}

# pragma mark Command

- (void)commandLogin:(NSString *)username and:(NSString *)password {
    // LOGIN command
    _response = [NSMutableString new];
    _commandCount ++;
    _currentCommand = @"login";
    NSString *command = [NSString stringWithFormat: @"LOGIN %@ %@",username,password];
    NSString *sendCommand = [NSString stringWithFormat: @"a%i %@\r\n", _commandCount, command];
    NSData *sendData = [sendCommand dataUsingEncoding:NSASCIIStringEncoding];
    [_outputStream write:[sendData bytes] maxLength:[sendData length]];
}

- (void)commandList {
    // LIST command
    _response = [NSMutableString new];
    _commandCount ++;
    _currentCommand = @"list";
    NSString *command = [NSString stringWithFormat: @"LIST \"\" \"*\""];
    NSString *sendCommand = [NSString stringWithFormat: @"a%i %@\r\n", _commandCount, command];
    NSData *sendData = [sendCommand dataUsingEncoding:NSASCIIStringEncoding];
    [_outputStream write:[sendData bytes] maxLength:[sendData length]];
}

- (void)commandSelect:(NSString *)mailBox {
    // SELECT command
    _response = [NSMutableString new];
    _commandCount ++;
    _currentCommand = @"select";
    NSString *command = [NSString stringWithFormat: @"SELECT \"%@\"", mailBox];
    NSString *sendCommand = [NSString stringWithFormat: @"a%i %@\r\n", _commandCount, command];
    NSData *sendData = [sendCommand dataUsingEncoding:NSASCIIStringEncoding];
    [_outputStream write:[sendData bytes] maxLength:[sendData length]];
}

- (void)commandFetch:(NSString *)sequence and:(NSString *)fields {
    // FETCH command
    _response = [NSMutableString new];
    _commandCount ++;
    _currentCommand = @"fetch";
    NSString *command = [NSString stringWithFormat: @"FETCH %@ %@",sequence,fields];
    NSString *sendCommand = [NSString stringWithFormat: @"a%i %@\r\n", _commandCount, command];
    NSData *sendData = [sendCommand dataUsingEncoding:NSASCIIStringEncoding];
    [_outputStream write:[sendData bytes] maxLength:[sendData length]];
}

@end
