//
//  ImgurUploaderAppDelegate.h
//  ImgurUploader
//
//  Created by Sony Theakanath on 2/7/13.
//  Copyright 2013 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImgurUploaderViewController;

@interface ImgurUploaderAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ImgurUploaderViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ImgurUploaderViewController *viewController;

@end

