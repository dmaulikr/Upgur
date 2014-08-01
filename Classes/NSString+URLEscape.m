//
//  NSString+URLEscape.m
//  ThoughtBackDesktop
//
//  Created by Sony Theakanath on 2/7/13.
//  Copyright 2013 Sony Theakanath. All rights reserved.
//

#import "NSString+URLEscape.h"


@implementation NSString(NSString_URLEscape)

-(NSString*)stringByEscapingValidURLCharacters
{
	NSString *escaped = [self stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
	escaped = [escaped stringByReplacingOccurrencesOfString:@"!" withString:@"%21"];
	escaped = [escaped stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
	escaped = [escaped stringByReplacingOccurrencesOfString:@"(" withString:@"%28"];
	escaped = [escaped stringByReplacingOccurrencesOfString:@")" withString:@"%29"];
	escaped = [escaped stringByReplacingOccurrencesOfString:@"*" withString:@"%2A"];
	escaped = [escaped stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
	escaped = [escaped stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
	escaped = [escaped stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
	escaped = [escaped stringByReplacingOccurrencesOfString:@";" withString:@"%3B"];
	escaped = [escaped stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
	escaped = [escaped stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
	
	return escaped;
	
}

@end
