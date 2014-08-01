//
//  ThoughtSender.h
//  ThoughtBackDesktop
//
//  Created by Sony Theakanath on 2/7/13.
//  Copyright 2013 Sony Theakanath. All rights reserved.
//


@protocol ImgurUploaderDelegate

-(void)uploadFailedWithError:(NSError*)error;
- (void) animateUploadingLoad;
- (void) uploadingFinished;
- (void) writeData:(NSString*)link;

@end

@interface ImgurUploader : NSObject <NSXMLParserDelegate>  {
	id<ImgurUploaderDelegate> delegate;
	NSMutableData *receivedData;
	NSString* imageURL;
	NSString* currentNode;
}

-(void)uploadImage:(UIImage*)image;

@property (assign) id<ImgurUploaderDelegate> delegate;

@end
