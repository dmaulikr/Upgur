//
//  ThoughtSender.m
//  ThoughtBackDesktop
//
//  Created by Sony Theakanath on 2/7/13.
//  Copyright 2013 Sony Theakanath. All rights reserved.
//

#import "ImgurUploader.h"
#import "NSString+URLEncoding.h"
#import "NSData+Base64.h"
#import "ImgurUploaderViewController.h"
#import <dispatch/dispatch.h>


@implementation ImgurUploader

@synthesize delegate;

-(void)uploadImage:(UIImage*)image {
    [delegate animateUploadingLoad];
	dispatch_queue_t queue = dispatch_queue_create("com.Blocks.task",NULL);
	dispatch_queue_t main = dispatch_get_main_queue();
	dispatch_async(queue,^{
		NSData *imageData  = UIImageJPEGRepresentation(image, 0.3); // High compression due to 3G.
		NSString *imageB64   = [imageData base64EncodingWithLineLength:0];
		imageB64 = [imageB64 encodedURLString];
		dispatch_async(main,^{
			NSString *uploadCall = [NSString stringWithFormat:@"key=%@&image=%@",@"7e6c4cf4857e8d6cee1d123eee6edb16",imageB64];
			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.imgur.com/2/upload"]];
			[request setHTTPMethod:@"POST"];
            NSLog(@"%@", uploadCall);
			[request setValue:[NSString stringWithFormat:@"%d",[uploadCall length]] forHTTPHeaderField:@"Content-length"];
			[request setHTTPBody:[uploadCall dataUsingEncoding:NSUTF8StringEncoding]];
			NSURLConnection *theConnection=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
			if (theConnection)  {
				receivedData=[[NSMutableData data] retain];
            } else {
			}
		});
	});
}


-(void)dealloc {
	[super dealloc];
	[imageURL release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[delegate uploadFailedWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSXMLParser* parser = [[NSXMLParser alloc] initWithData:receivedData];
	[parser setDelegate:self];
	[parser parse];
}


-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	currentNode = elementName;
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if( [currentNode isEqualToString:elementName])
		currentNode = @"";
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if( [currentNode isEqualToString:@"original"] ) {
		imageURL = [string retain];
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:imageURL];
        NSLog(@"Copied to clipboard!");
        NSLog(@"URL: %@", imageURL);
        [delegate uploadingFinished];
        [delegate writeData:imageURL];
	}
}

@end
