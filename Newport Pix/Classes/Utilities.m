//
//  Utilities.m
//  Newport Pix
//
//  Created by Mirko Delgado on 09/16/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

/**********************************************
 *
 **********************************************/

+(NSString *)getNextPictureName: (NSUInteger) PhotoCount
{
    NSMutableString *filePath = [NSMutableString stringWithString:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/DEP"]];
    
    if (PhotoCount < 10)
    {
        [filePath appendString:@"0"];
        [filePath appendString:[NSString stringWithFormat:@"%lu", (unsigned long)PhotoCount]];
    }
    else
    {
        [filePath appendString:[NSString stringWithFormat:@"%lu", (unsigned long)PhotoCount]];
    }
    
    [filePath appendString:@".jpg"];
//    [filePath appendString:@".JPG"];
    
	return filePath;
}

/**********************************************
 *
 **********************************************/

+(void) removeJPGFiles
{
    NSFileManager  *manager = [NSFileManager defaultManager];
    
    // the preferred way to get the apps documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // grab all the files in the documents dir
    NSArray *allFiles = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    // filter the array for only jpg files
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"];
//    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.JPG'"];
    NSArray *jpgFiles = [allFiles filteredArrayUsingPredicate:fltr];
    
    // use fast enumeration to iterate the array and delete the files
    for (NSString *jpgFile in jpgFiles)
    {
        NSError *error = nil;
        [manager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:jpgFile] error:&error];
        NSAssert(!error, @"Assertion: JPG file deletion shall never throw an error");
    }
}

/**********************************************
 *
 **********************************************/

+(NSArray *) getPhotoFiles
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // the preferred way to get the apps documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // grab all the files in the documents dir
    NSArray *allFiles = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    // filter the array for only jpg files
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"];
//    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.JPG'"];
    NSArray *jpgFiles = [allFiles filteredArrayUsingPredicate:fltr];

    NSMutableArray *jpgFilesWithPath = [[NSMutableArray alloc] initWithCapacity: [jpgFiles count]];

    NSString *NameWithPath;
    NSUInteger i = 0;
    
    for (NSString *jpgFile in jpgFiles)
    {
        NameWithPath = [documentsDirectory stringByAppendingPathComponent:jpgFile];
        
        [jpgFilesWithPath insertObject:NameWithPath atIndex:i];
        
        i++;
    }
    
//    [jpgFilesWithPath insertObject:nil atIndex:i];
        
    return jpgFilesWithPath;
}

/**********************************************
 *
 **********************************************/

+(void) fixImageOrientation;
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // the preferred way to get the apps documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // grab all the files in the documents dir
    NSArray *allFiles = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    // filter the array for only jpg files
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"];
//    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.JPG'"];
    NSArray *jpgFiles = [allFiles filteredArrayUsingPredicate:fltr];
    
    NSMutableArray *jpgFilesWithPath = [[NSMutableArray alloc] initWithCapacity: [jpgFiles count]];
    
    NSString *NameWithPath;
    NSUInteger i = 0;
    
    for (NSString *jpgFile in jpgFiles)
    {
        NameWithPath = [documentsDirectory stringByAppendingPathComponent:jpgFile];
        
        [jpgFilesWithPath insertObject:NameWithPath atIndex:i];
        
//        UIImage *image = [UIImage imageNamed:NameWithPath];
        UIImage *image = [UIImage imageWithContentsOfFile:NameWithPath];
        
        
        UIImage *new_image = [self fixrotation:image];
//        UIImage *new_image = [self rotate:image : image.imageOrientation];
        
        [UIImageJPEGRepresentation(new_image, 1.0) writeToFile:NameWithPath atomically:YES];
        
        i++;
    }    
}

/**********************************************
 *
 **********************************************/

+(NSArray *) getFilesForSend
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // the preferred way to get the apps documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // grab all the files in the documents dir
    NSArray *allFiles = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    // filter the array for only jpg files
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"];
//    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.JPG'"];
    NSArray *jpgFiles = [allFiles filteredArrayUsingPredicate:fltr];
    
    int totalFiles = (int)[jpgFiles count] + 1;
    
    NSMutableArray *sendFilesWithPath = [[NSMutableArray alloc] initWithCapacity: totalFiles];
    
    NSString *NameWithPath;
    NSUInteger i = 0;
    
    for (NSString *jpgFile in jpgFiles)
    {
        NameWithPath = [documentsDirectory stringByAppendingPathComponent:jpgFile];
        
        [sendFilesWithPath insertObject:NameWithPath atIndex:i];
        
        i++;
    }
    
    NSPredicate *depicsfltr = [NSPredicate predicateWithFormat:@"self MATCHES 'depics'"];
    NSArray *depicsFile = [allFiles filteredArrayUsingPredicate:depicsfltr];

    NameWithPath = [documentsDirectory stringByAppendingPathComponent: [depicsFile objectAtIndex: 0]];
    
    [sendFilesWithPath insertObject:NameWithPath atIndex:i];
    
    return sendFilesWithPath;
}

/**********************************************
 *
 **********************************************/

+ (UIImage *)fixrotation:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp) return image;
        CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

/**********************************************
 *
 **********************************************/

static inline double radians (double degrees) {return degrees * M_PI/180;}
+ (UIImage *) rotate: (UIImage *) src : (UIImageOrientation) orientation
{
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, radians(90));
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(-90));
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, radians(90));
    }
    
    [src drawAtPoint:CGPointMake(0, 0)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
