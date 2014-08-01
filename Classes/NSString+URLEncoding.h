//
//  NSString+URLEncoding.h
//
//  Created by Sony Theakanath on 2/7/13.
//  Copyright 2013 Sony Theakanath. All rights reserved.


#import <Foundation/Foundation.h>

@interface NSString (OAURLEncodingAdditions)

- (NSString *)encodedURLString;
- (NSString *)encodedURLParameterString;
- (NSString *)decodedURLString;
- (NSString *)removeQuotes;
@end
