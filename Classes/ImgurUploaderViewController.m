//
//  ImgurUploaderViewController.m
//  ImgurUploader
//
//  Created by Sony Theakanath on 2/7/13.
//  Copyright 2013 Sony Theakanath. All rights reserved.
//

#import "ImgurUploaderViewController.h"

@implementation ImgurUploaderViewController

@synthesize interfaceArray, vImagePreview, stillImageOutput, popoverController, savedLinks, device;

#pragma mark - Action Functions

-(IBAction)showUploads:(id)sender {
   if ([self.popoverController isPopoverVisible]) {
      [self.popoverController dismissPopoverAnimated:YES];
      [popoverController release];
   } else {
      UITableViewController *controller = [[UITableViewController alloc ] initWithStyle: UITableViewStylePlain];
      controller.title = @"Uploads";
      UITableView *saveddata = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, 480)];
      [saveddata setDataSource:self];
      [saveddata setDelegate:self];
      //self.popoverController.contentViewController
      [saveddata reloadData];
      [controller setTableView:saveddata];
      [saveddata release];
      UINavigationController* popoverContent = [[UINavigationController alloc]initWithRootViewController:controller];
      UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(canceluploads)];
      controller.navigationItem.rightBarButtonItem = cancelButton;
      [cancelButton release];
      if([device isEqualToString:@"iPad"]) {
         self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
         [self.popoverController setPopoverContentSize:CGSizeMake(320, 480)];
         popoverController.delegate = self;
         [self.popoverController presentPopoverFromRect:[sender bounds] inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
      } else {
         [self presentModalViewController:popoverContent animated:YES];
      }
   }
}

-(IBAction)showLibraryPicker: (id)sender {
   if([self connectedToInternet]) {
      if ([self.popoverController isPopoverVisible]) {
         [self.popoverController dismissPopoverAnimated:YES];
         [popoverController release];
      } else {
         if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.mediaTypes = [NSArray arrayWithObjects: (NSString *) kUTTypeImage, nil];
            picker.allowsEditing = NO;
            if([device isEqualToString:@"iPad"]) {
               self.popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
               popoverController.delegate = self;
               [self.popoverController presentPopoverFromRect:[sender bounds] inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
               newMedia = NO;
            } else {
               [self presentModalViewController:picker animated:YES];
            }
         }
      }
   } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Not Connected to the Internet!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
      [alert show];
      [alert release];
   }
}

-(IBAction)canceluploads {
   if([device isEqualToString:@"iPad"]) {
      [self.popoverController dismissPopoverAnimated:YES];
      [popoverController release];
   } else {
      [self dismissViewControllerAnimated:YES completion:nil];
   }
}
-(IBAction)takePicture {
   if([self connectedToInternet]) {
      AVCaptureConnection *videoConnection = nil;
      for (AVCaptureConnection *connection in stillImageOutput.connections) {
         for (AVCaptureInputPort *port in [connection inputPorts])
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
               videoConnection = connection;
               break;
            }
         if (videoConnection) { break; }
      }
      [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *takenpicture = [[UIImage alloc] initWithData:imageData];
         [uploader uploadImage:takenpicture];
      }];
   } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Not Connected to the Internet!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
      [alert show];
      [alert release];
   }
}


#pragma mark - Table View Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   [self refreshSavedLinks];
   return [savedLinks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
   if (cell == nil)
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
   [self refreshSavedLinks];
   NSString *date = [[savedLinks objectAtIndex:indexPath.row] objectAtIndex:0];
   cell.textLabel.text = date;
   cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   [self refreshSavedLinks];
   index = indexPath.row;
   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Selection" message:[NSString stringWithFormat:@"Image taken on:\n %@", [[savedLinks objectAtIndex:indexPath.row] objectAtIndex:0]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Copy Link to Clipboard", @"View Image", nil];
   [alert show];
   [alert release];
   [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
   [self refreshSavedLinks];
   if(buttonIndex == 1) {
      UIPasteboard *pb = [UIPasteboard generalPasteboard];
      [pb setString:[[savedLinks objectAtIndex:index] objectAtIndex:1]];
      UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"Copied!" message:@"Imgur URL Copied to Clipboard! " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [myalert show];
      [myalert release];
   } else if (buttonIndex == 2) {
      NSString *link = [[savedLinks objectAtIndex:index] objectAtIndex:1];
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@",link]]];
   }
}

#pragma mark - Data Functions

- (void) writeData:(NSString*)link {
   NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString* documentsDirectory = [paths objectAtIndex:0];
   NSString* dataPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"data.plist"]];
   NSFileManager *fm = [[NSFileManager alloc] init];
   NSMutableArray *data = [[NSMutableArray alloc] init];
   if([fm fileExistsAtPath:dataPath])
      data = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];

   NSDate *now = [NSDate date];
   NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
   [dateFormat setDateFormat: @"MMM dd, yyyy HH:mm:ss"];
   NSString *dateString = [[dateFormat stringFromDate:now] capitalizedString];
   NSArray* newdata = [[NSArray alloc] initWithObjects: dateString, link, nil];
   [data insertObject:newdata atIndex:0];

   [[NSKeyedArchiver archivedDataWithRootObject:data] writeToFile:dataPath atomically:YES];
}

- (void) refreshSavedLinks {
   NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString* documentsDirectory = [paths objectAtIndex:0];
   NSString* dataPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"data.plist"]];
   NSFileManager *fm = [[NSFileManager alloc] init];
   if([fm fileExistsAtPath:dataPath])
      savedLinks = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
}

-(void)uploadFailedWithError:(NSError *)error {
   [[interfaceArray objectAtIndex:4] setAlpha:0];
   [[interfaceArray objectAtIndex:5] stopAnimating];
   UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error!" message: @"Failed to Upload Image!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
   [alert show];
   [alert release];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
   if([device isEqualToString:@"iPad"]) {
      [self.popoverController dismissPopoverAnimated:true];
      [popoverController release];
   } else {
      [self dismissModalViewControllerAnimated:YES];
   }
   NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
   [self dismissViewControllerAnimated:YES completion:nil];

   if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
      UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
      if (newMedia)
         UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
      [uploader uploadImage:image];
   }
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
   if (error) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Save failed" message: @"Failed to save image" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
      [alert release];
   }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
   [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Interface Functions

- (BOOL)connectedToInternet {
   Reachability *reachability = [Reachability reachabilityForInternetConnection];
   NetworkStatus networkStatus = [reachability currentReachabilityStatus];
   return !(networkStatus == NotReachable);
}

- (void) animateUploadingLoad {
   [[interfaceArray objectAtIndex:4] setImage:[UIImage imageNamed:@"Uploading"]];
   [[interfaceArray objectAtIndex:4] setAlpha:1];
   [[interfaceArray objectAtIndex:5] startAnimating];
}

- (void) uploadingFinished {
   [[interfaceArray objectAtIndex:4] setImage:[UIImage imageNamed:@"Uploaded"]];
   [[interfaceArray objectAtIndex:5] stopAnimating];
   [UIView animateWithDuration:1 delay:0.5 options:UIViewAnimationCurveLinear animations:^ {
      [[interfaceArray objectAtIndex:4] setAlpha:0];
   } completion:^(BOOL finished){
   }];
}

- (BOOL) cameraExists {
   BOOL *exists = false;
   NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
   for (AVCaptureDevice *device1 in videoDevices) {
      if (device1.position == AVCaptureDevicePositionFront)
         exists = true;
      else if (device1.position == AVCaptureDevicePositionBack)
         exists = true;
      else if (device1.position == AVCaptureDevicePositionUnspecified)
         exists = true;
   }
   return exists;
}

- (void) startImagePreview:(UIView*)imagePreview {
   if([self cameraExists]) {
      [[interfaceArray objectAtIndex:6] setAlpha:0];
      AVCaptureSession *session = [[AVCaptureSession alloc] init];
      session.sessionPreset = AVCaptureSessionPresetMedium;
      AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
      captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
      CGFloat scale = [[UIScreen mainScreen] scale];

      CGRect bounds= imagePreview.layer.bounds;
      bounds.size.width*=scale;
      bounds.size.height*=scale;
      captureVideoPreviewLayer.position=CGPointMake(imagePreview.bounds.size.width/2, imagePreview.bounds.size.height/2);
      captureVideoPreviewLayer.bounds = imagePreview.bounds;
      [imagePreview.layer addSublayer:captureVideoPreviewLayer];
      
      AVCaptureDevice *device1 = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
      NSError *error = nil;
      AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device1 error:&error];
      if (!input)
         NSLog(@"ERROR: trying to open camera: %@", error);
      [session addInput:input];
      stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
      NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
      [stillImageOutput setOutputSettings:outputSettings];
      [session addOutput:stillImageOutput];
      [session startRunning];
   } else {
      [[interfaceArray objectAtIndex:6] setAlpha:1];
   }
}

- (void) startVariables {
   CGRect screenRect = [[UIScreen mainScreen] bounds];
   CGFloat screenWidth = screenRect.size.width;
   CGFloat screenHeight = screenRect.size.height;
   interfaceArray = [[NSArray alloc] initWithObjects:
                     [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)], //Photo Screen
                     [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2-40, screenHeight-110, 80, 80)], //Take Photo Button
                     [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/4-20, screenHeight-93, 168, 49)], //Library Button
                     [[UIButton alloc] initWithFrame:CGRectMake((screenWidth-screenWidth/4)-148, screenHeight-93, 168, 49)], //Uploads Button
                     [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2-100, screenHeight/2-100, 200, 200)], //Uploading Showing
                     [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(screenWidth/2-47, screenHeight/2-60, 100, 100)], //Loading indicator
                     [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,screenWidth, screenHeight)],
                     nil];
   
   NSString* dataPath = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"]];
   if([[[NSFileManager alloc] init] fileExistsAtPath:dataPath])
      savedLinks = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
   NSLog(@"In Array: %@", savedLinks);
   
   device = [UIDevice currentDevice].model;
}

- (void) startInterface {
   CGRect screenRect = [[UIScreen mainScreen] bounds];
   CGFloat screenWidth = screenRect.size.width;
   CGFloat screenHeight = screenRect.size.height;
   [self startImagePreview:[interfaceArray objectAtIndex:0]];
   [[interfaceArray objectAtIndex:1] setBackgroundImage:[UIImage imageNamed:@"photoButton"] forState:UIControlStateNormal];
   [[interfaceArray objectAtIndex:1] addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
   [[interfaceArray objectAtIndex:2] setBackgroundImage:[UIImage imageNamed:@"libraryButton"] forState:UIControlStateNormal];
   [[interfaceArray objectAtIndex:2] addTarget:self action:@selector(showLibraryPicker:) forControlEvents:UIControlEventTouchUpInside];
   [[interfaceArray objectAtIndex:3] setBackgroundImage:[UIImage imageNamed:@"uploadsButton"] forState:UIControlStateNormal];
   [[interfaceArray objectAtIndex:3] addTarget:self action:@selector(showUploads:) forControlEvents:UIControlEventTouchUpInside];
   [[interfaceArray objectAtIndex:4] setImage:[UIImage imageNamed:@"Uploading"]];
   [[interfaceArray objectAtIndex:4] setAlpha:0];
   [(UIView *)[interfaceArray objectAtIndex:5] setTransform:CGAffineTransformMakeScale(1.5, 1.5)];
   [[interfaceArray objectAtIndex:6] setImage:[UIImage imageNamed:@"ifNoCamera"]];
   [[interfaceArray objectAtIndex:6] setAlpha:0];
   NSLog(@"%@", device);
   if([device isEqualToString:@"iPhone"] ||[device isEqualToString:@"iPod touch"] || [device isEqualToString:@"iPhone Simulator"]) {
      [[interfaceArray objectAtIndex:2] setFrame:CGRectMake(screenWidth/4-74, screenHeight-88, 112, 33)];
      [[interfaceArray objectAtIndex:3] setFrame:CGRectMake((screenWidth-screenWidth/4)-38, screenHeight-88, 112, 33)];
      [[interfaceArray objectAtIndex:6] setImage:[UIImage imageNamed:@"noCamera-iPhone"]];
   }
   for (UIView *view in interfaceArray)
      if(![view superview])
         [[self view] addSubview:view];
   [[self view] insertSubview:[interfaceArray objectAtIndex:6] atIndex:1];
}

- (void) setBackground {
   if([self cameraExists]) {
      [[interfaceArray objectAtIndex:6] setAlpha:0];
   } else {
      [[interfaceArray objectAtIndex:6] setAlpha:1];
   }
}

- (void)viewDidLoad {
   [super viewDidLoad];
   uploader = [[ImgurUploader alloc] init];
   uploader.delegate = self;
   [self startVariables];
   [self startInterface];
   [self setBackground];
}

- (void)viewDidUnload {
   self.popoverController = nil;
}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
}

- (void)dealloc {
   [popoverController release];
   [super dealloc];
}

@end
