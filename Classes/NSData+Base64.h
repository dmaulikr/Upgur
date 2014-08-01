//
//  NSData+Base64.m
//
//  Created by Sony Theakanath on 2/7/13.
//  Copyright 2013 Sony Theakanath. All rights reserved.
//

@interface NSData (Base64)

+ (NSData *) dataWithBase64EncodedString:(NSString *) string;

- (id) initWithBase64EncodedString:(NSString *) string;

- (NSString *) base64EncodingWithLineLength:(unsigned int) lineLength;

@end