//
//  Globals.h
//  Newport Pix
//
//  Created by Mirko Delgado on 08/20/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

@interface Globals : NSObject {
    
    NSString *userID;

    NSString *recID;
    NSString *vendorID;
    NSString *depotID;
    NSString *billToCID;
    NSString *billToVendorID;
    NSString *billToDepotID;
    NSString *billToClientName;
    
    BOOL activeClient;
    BOOL pixClient;

    NSString *row1;
    NSString *row2;
    NSString *row3;
    NSString *row4;
    NSString *row5;
    NSString *row6;
}

@property(nonatomic,retain)NSString *userID;

@property(nonatomic,retain)NSString *recID;
@property(nonatomic,retain)NSString *vendorID;
@property(nonatomic,retain)NSString *depotID;
@property(nonatomic,retain)NSString *billToCID;
@property(nonatomic,retain)NSString *billToVendorID;
@property(nonatomic,retain)NSString *billToDepotID;
@property(nonatomic,retain)NSString *billToClientName;

@property(nonatomic,retain)NSString *row1;
@property(nonatomic,retain)NSString *row2;
@property(nonatomic,retain)NSString *row3;
@property(nonatomic,retain)NSString *row4;
@property(nonatomic,retain)NSString *row5;
@property(nonatomic,retain)NSString *row6;

+(Globals*) getInstance;

+(BOOL) getActiveClient;
+(void) setActiveClient: (BOOL) newActiveClient;

+(BOOL) getPixClient;
+(void) setPixClient: (BOOL) newPixClient;

@end

