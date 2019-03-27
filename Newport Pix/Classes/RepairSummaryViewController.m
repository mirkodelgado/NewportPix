//
//  RepairSummaryViewController.m
//  Newport Pix
//
//  Created by Mirko Delgado on 08/15/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "RepairSummaryViewController.h"
#import "CallsDao.h"
#import "Globals.h"
#import "Utilities.h"
#import "WriteDamageInfo.h"
#import "CommunicationManager.h"
#import "DBUtils.h"
#import "NetworkUtil.h"
#import "InfoDao.h"

NSUInteger RepairSummaryPhotoCount = 0;

@interface RepairSummaryViewController ()

@end

@implementation RepairSummaryViewController

NSMutableData* responseData;

NSArray *localCaptions;
NSArray *localImages;

FGalleryViewController *localGallery;

/**********************************************
 *
 **********************************************/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/**********************************************
 *
 **********************************************/

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [Utilities removeJPGFiles];
    
    self.rs_progress.progress = 1;
    
    [self.rs_progress setHidden:YES];
    
    NSString *call = self.callNumber;
    
    CallsDao *callsDao = [[CallsDao alloc]initWithDataBase];
    NSArray *callInfo = [callsDao getCallSummaryInfo: call];
    [callsDao closeAll];
    
    Globals *glbls =[Globals getInstance];
    
    self.billtoClientTxt.text = glbls.billToClientName;
    
    self.callNumberTxt.text = [callInfo objectAtIndex:0];
    self.equipmentIDTxt.text = [callInfo objectAtIndex:1];
    self.relatedIDTxt.text = [callInfo objectAtIndex:2];
    self.photosTakenTxt.text = [callInfo objectAtIndex:3];
    self.callStatusTxt.text = [callInfo objectAtIndex:4];
    
    RepairSummaryPhotoCount = [[callInfo objectAtIndex:3] intValue];
}

/**********************************************
 *
 **********************************************/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark IBActions

/**********************************************
 *
 **********************************************/

- (IBAction)reviewPhotosAction:(id)sender
{
    localImages = [Utilities getPhotoFiles];        // get the photos taken
    
    int count = [localImages count];
    
    NSMutableArray *lCaptions = [[NSMutableArray alloc] initWithCapacity: count];
    
    int j = 0;
    
    for (int i = 0; i < count; i++)
    {
        j = j + 1;
        
        NSString *pCountString = [NSString stringWithFormat:@"Photo %d",j];
        
        [lCaptions insertObject: pCountString atIndex:i];
    }
    
    localCaptions = (NSArray *) lCaptions;
    
    localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
    [self.navigationController pushViewController:localGallery animated:YES];
}

/**********************************************
 *
 **********************************************/

- (IBAction)takePictureAction:(id)sender
{
	PixLog(@"-[%@ %@]", [self class], NSStringFromSelector(_cmd));
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    [imagePicker setDelegate:self];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    else // The device doesn't have a camera, so use something like the photos album
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    
    imagePicker.showsCameraControls = YES;
//    imagePicker.wantsFullScreenLayout = YES;
    
//    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

/**********************************************
 *
 **********************************************/

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];

    RepairSummaryPhotoCount = RepairSummaryPhotoCount + 1;

    self.photosTakenTxt.text = [NSString stringWithFormat:@"%d", RepairSummaryPhotoCount];
    
    NSString *filePath = [Utilities getNextPictureName:RepairSummaryPhotoCount];

    // Create paths to output images
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
    
    // Let's check to see if files were successfully written...
    
    // Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    // Write out the contents of home directory to console
    PixLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    
    // Code here to work with media
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Newport Pix"
                                                    message:@"Would you like to take another picture?"
                                                    delegate:nil
                                                    cancelButtonTitle:@"No"
                                                    otherButtonTitles:@"Yes", nil];
    alert.delegate = self;    
    
    [alert show];
}

/**********************************************
 *
 **********************************************/

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**********************************************
 *
 **********************************************/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    switch (buttonIndex) {
        case 0:         // No
            break;
            
        case 1:         // Yes
            
            [imagePicker setDelegate:self];
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            else // The device doesn't have a camera, so use something like the photos album
                [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            
            imagePicker.allowsEditing = YES;
            [self presentViewController:imagePicker animated:YES completion:nil];
            break;
            
        default:
            break;
    }
}

/**********************************************
 *
 **********************************************/

- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
    int num;
    
    if (gallery == localGallery )
        num = [localImages count];
    
    return num;
}

/**********************************************
 *
 **********************************************/

//- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
//{
//	if( gallery == localGallery ) {
//		return FGalleryPhotoSourceTypeLocal;
//	}
//	else return FGalleryPhotoSourceTypeNetwork;
//}

/**********************************************
 *
 **********************************************/

- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    NSString *caption;
    
    if( gallery == localGallery )
        caption = [localCaptions objectAtIndex:index];
    
    return caption;
}

/**********************************************
 *
 **********************************************/

- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return [localImages objectAtIndex:index];
}

/**********************************************
 *
 **********************************************/

//- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
//return [networkImages objectAtIndex:index];
//    return nil;
//}

/**********************************************
 *
 **********************************************/

- (void)handleTrashButtonTouch:(id)sender {
    // here we could remove images from our local array storage and tell the gallery to remove that image
    // ex:
    //[localGallery removeImageAtIndex:[localGallery currentIndex]];
}

#pragma mark NSURLConnection Delegate Methods

/**********************************************
 *
 **********************************************/

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    
    if ([httpResponse statusCode] == 200)
        responseData = [[NSMutableData alloc] init];
    else
        PixLogAll(@"Status code: %ld", (long)[httpResponse statusCode]);
}

/**********************************************
 *
 **********************************************/

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    /*
     float progress = totalBytesWritten*1.0/totalBytesExpectedToWrite;
     
     dispatch_async(dispatch_get_main_queue(),^ {
     [self.progress setProgress:progress animated:YES];
     //        self.progress.progress = progress;
     });
     
     PixLogAll(@"Progress =%f",progress);
     
     PixLogAll(@"Received: %ld bytes (Downloaded: %ld bytes)  Expected: %ld bytes.\n",
     (long)bytesWritten, (long)totalBytesWritten, (long)totalBytesExpectedToWrite);
     */
    
    if ([self respondsToSelector:@selector(progress)])
    {
        float progress = totalBytesWritten*1.0/totalBytesExpectedToWrite;
        
        //        self.progress.progress = ((float)totalBytesWritten / totalBytesExpectedToWrite) * 100.0;
        [self.rs_progress setProgress:progress animated:YES];
    }
}

/**********************************************
 *
 **********************************************/

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to the instance variable you declared
    
    [responseData appendData:data];
}

/**********************************************
 *
 **********************************************/

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

/**********************************************
 *
 **********************************************/

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    self.rs_progress.progress = 1;
    [self.rs_progress setHidden:YES];
    
    DBUtils *dbUtils = [[DBUtils alloc]initWithDataBase];
    [dbUtils processRequest:responseData];
    [dbUtils closeAll];
    
    InfoDao *info = [[InfoDao alloc]initWithDataBase];
    ResponseInfo *respInfo = [info getResponseInfo];
    [info closeAll];
    
    NSMutableString *resp;
    NSString *title;
    
    if ([[respInfo getStatus] isEqualToString:@"pass"])
    {
        title = @"Photo(s) Received";
        
        if ([[respInfo getCallNumber] length] == 0)
        {
            resp = [NSMutableString stringWithString:@"Equipment ID: "];
            [resp appendString:[respInfo getUnitNumber]];
            [resp appendString:@"\r\nPhoto Count: "];
            [resp appendString:[respInfo getPhotoCount]];
        }
        else
        {
            resp = [NSMutableString stringWithString:@"Call Number: "];
            [resp appendString:[respInfo getCallNumber]];
            [resp appendString:@"\r\nEquipment ID: "];
            [resp appendString:[respInfo getUnitNumber]];
            [resp appendString:@"\r\nPhoto Count: "];
            [resp appendString:[respInfo getPhotoCount]];
        }
    }
    else
    {
        title = @"Photo Submit Error";
        
        resp = [NSMutableString stringWithString:@"An error occurred processing estimate for unit "];
        [resp appendString:[respInfo getUnitNumber]];
        [resp appendString:@". Data has been received, Newport has been notified."];
    }
    
//    [Utilities removeJPGFiles];
//    RepairSummaryPhotoCount = 0;
//    _TxtEquipmentID.text = @"";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:resp
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

/**********************************************
 *
 **********************************************/

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

@end
