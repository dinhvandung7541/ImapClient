//
//  Ultilities.m
//  ImapClient
//
//  Created by Trần Quang Tuấn on 04/05/2016.
//  Copyright © 2016 Alleria. All rights reserved.
//

#import "Utilities.h"
#import "Base64.h"
//#import "ImapEncoding.h"

@implementation Utilities

+ (NSString *) decodeMailBoxName:(NSString *)src {
    // RFC 2152
    NSMutableString *s = [NSMutableString string];
    NSMutableString *code = [NSMutableString string];
    
    bool base64 = false;
    for (int i = 0; i < src.length; i++)
    {
        char c = [src characterAtIndex:i];
        if (c == '&')
            base64 = true;
        else if (c == '-')
        {
            base64 = false;
            NSString *decoded = [[NSString alloc] initWithData:[Base64 decodeBase64WithString:code]
                                                      encoding:NSUnicodeStringEncoding];
            [s appendString:decoded];
            code = [NSMutableString string];
        }
        else
        {
            if (c == ',')
                c = '/';
            if (base64)
                [code appendFormat:@"%c", c];
            else
                [s appendFormat:@"%c", c];
        }
    }
    
    return s;
}

+ (NSString *)decodeHeader:(NSString *)src {
    NSMutableString *result = [NSMutableString stringWithString:src];
    // RFC 2047 encoded-word
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"=\\?(.*?)\\?(.*?)\\?(.*?)\\?=" options:0 error:NULL];
    NSArray *matches = [regex matchesInString:src options:0 range:NSMakeRange(0, src.length)];
    for (int i = (int)matches.count-1; i >= 0; i--)
    {
        NSTextCheckingResult *match = [matches objectAtIndex:i];
        
        NSString *type = [src substringWithRange:[match rangeAtIndex:2]];
        NSString *text = [src substringWithRange:[match rangeAtIndex:3]];
        
        if ([type isEqual:@"B"])
        {
            NSData *strData = [Base64 decodeBase64WithString:text];
            NSString *str = [[NSString alloc] initWithData:strData
                                                  encoding:NSUTF8StringEncoding];
            if (str != NULL)
                [result replaceCharactersInRange:match.range withString:str];
        }
        else if ([type isEqual:@"Q"])
        {
            NSData *strData = [self decodeQuotedPrintable:text];
            NSString *str = [[NSString alloc] initWithData:strData
                                                  encoding:NSUTF8StringEncoding];
            if (str != NULL)
                [result replaceCharactersInRange:match.range withString:str];
        }
    }
    
    return result;
}

+ (NSData *)decodeQuotedPrintable:(NSString *)s
{
    NSMutableData *data = [NSMutableData data];
    char wsp = ' ';
    
    int i = 0;
    while (i < s.length)
    {
        unichar c = [s characterAtIndex:i];
        if (c == '=' && i < s.length-2)
        {
            NSScanner *scanner = [NSScanner scannerWithString:[s substringWithRange:NSMakeRange(i+1, 2)]];
            uint hex;
            if ([scanner scanHexInt:&hex])
            {
                [data appendBytes:&hex length:1];
                i += 2;
            }
        }
        else if (c == '_')
            [data appendBytes:&wsp length:1];
        else
            [data appendBytes:&c length:1];
        
        i++;
    }
    
    return data;
}


@end
