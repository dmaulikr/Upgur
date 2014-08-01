//
//  ImgurUploaderViewController.h
//  ImgurUploader
//
//  Created by Sony Theakanath on 2/7/13.
//  Copyright 2013 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/CGImageProperties.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "ImgurUploader.h"


@interface ImgurUploaderViewController : UIViewController <ImgurUploaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate> {
	ImgurUploader *uploader;
    UIPopoverController *popoverController;
    NSMutableArray *savedLinks;
    BOOL newMedia;
    NSInteger index;
    NSString *device;
}

-(IBAction)showLibraryPicker:(id)sender;
-(IBAction)showUploads:(id)sender;
-(IBAction)takePicture;
@property (nonatomic, retain) NSArray *interfaceArray;
@property (nonatomic, retain) NSString *device;
@property (nonatomic, retain) NSMutableArray *savedLinks;
@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property(nonatomic, retain) IBOutlet UIView *vImagePreview;
@property (nonatomic, retain) UIPopoverController *popoverController;

@end