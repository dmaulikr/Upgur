//
//  NSString+URLEncoding.m
//
//  Created by Sony Theakanath on 2/7/13.
//  Copyright 2013 Sony Theakanath. All rights reserved.


#import "NSString+URLEncoding.h"

@implementation NSString (OAURLEncodingAdditions)

- (NSString *)encodedURLString {
	NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}

- (NSString *)encodedURLParameterString {
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/=,!$&'()*+;[]@#?"), kCFStringEncodingUTF8);
	return [result autorelease];
}

- (NSString *)decodedURLString {
	NSString *result = (NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);
	return [result autorelease];
}

-(NSString *)removeQuotes {
	NSUInteger length = [self length];
	NSString *ret = self;
	if ([self characterAtIndex:0] == '"')
		ret = [ret substringFromIndex:1];
	if ([self characterAtIndex:length - 1] == '"')
		ret = [ret substringToIndex:length - 2];
	return ret;
}

@end
