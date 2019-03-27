//
//  ResponseInfo.h
//  Newport Pix
//
//  Created by Mirko Delgado on 09/18/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

@interface ResponseInfo : NSObject {
    
    NSString *status;
    NSString *callNumber;
    NSString *message;
    
    NSString *photoCount;
    
    NSString *unitID;
}

- (ResponseInfo*) getInstance;

-(void) setResponseInfo: (NSString *) Status : (NSString *) CallNumber : (NSString *) Message : (NSString *) UnitID : (NSString *) PhotoCount;

- (NSString *) getStatus;
- (NSString *) getCallNumber;
- (NSString *) getMessage;
- (NSString *) getPhotoCount;
- (NSString *) getUnitNumber;

@end

