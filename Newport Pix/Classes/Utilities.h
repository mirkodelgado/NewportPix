//
//  Utilities.h
//  Newport Pix
//
//  Created by Mirko Delgado on 09/16/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

@interface Utilities : NSObject

+(NSString *)getNextPictureName: (NSUInteger) PhotoCount;
+(void) removeJPGFiles;
+(NSArray *) getPhotoFiles;
+(void) fixImageOrientation;
+(NSArray *) getFilesForSend;

+(UIImage *) rotate: (UIImage *) src : (UIImageOrientation) orientation;

@end

