//
//  ResponseInfo.m
//  Newport Pix
//
//  Created by Mirko Delgado on 09/18/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "ResponseInfo.h"
#import "Globals.h"

@implementation ResponseInfo

NSString *status;
NSString *callNumber;
NSString *message;

NSString *photoCount;

NSString *unitID;

static ResponseInfo *instance = nil;

- (ResponseInfo *)getInstance
{
    @synchronized(self)
    {
        if (instance==nil)
        {
            instance = [ResponseInfo new];
            
            status = @"";
            callNumber = @"";
            message = @"";
            photoCount = @"0";
            
            unitID = @"";
        }
    }
    return instance;
}

/**********************************************
 *
 **********************************************/

- (void) setResponseInfo: (NSString *) Status : (NSString *) CallNumber : (NSString *) Message : (NSString *) UnitID : (NSString *) PhotoCount
{
    status = Status;
    callNumber = CallNumber;
    message = Message;
    unitID = UnitID;
    photoCount = PhotoCount;
}

/**********************************************
 *
 **********************************************/

- (NSString *) getStatus
{
    return status;
}

/**********************************************
 *
 **********************************************/

- (NSString *) getCallNumber
{
    return callNumber;
}

/**********************************************
 *
 **********************************************/

- (NSString *) getMessage
{
    return message;
}

/**********************************************
 *
 **********************************************/

- (NSString *) getPhotoCount
{
    return photoCount;
}

/**********************************************
 *
 **********************************************/

- (NSString *) getUnitNumber
{
    return unitID;
}

@end
