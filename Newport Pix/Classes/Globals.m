//
//  Globals.m
//  Newport Pix
//
//  Created by Mirko Delgado on 08/20/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "Globals.h"

static BOOL activeClient;
static BOOL pixClient;

@implementation Globals

@synthesize userID;

@synthesize recID;
@synthesize vendorID;
@synthesize depotID;
@synthesize billToCID;
@synthesize billToVendorID;
@synthesize billToDepotID;
@synthesize billToClientName;

@synthesize row1;
@synthesize row2;
@synthesize row3;
@synthesize row4;
@synthesize row5;
@synthesize row6;

static Globals *instance = nil;

+(Globals *)getInstance
{
    @synchronized(self)
    {
        if (instance==nil)
        {
            instance = [Globals new];
        }
    }
    return instance;
}

+ (BOOL)getActiveClient {
    return activeClient;
}

+ (void)setActiveClient:(BOOL)newActiveClient {
    activeClient = newActiveClient;
}

+ (BOOL)getPixClient {
    return pixClient;
}

+ (void)setPixClient:(BOOL)newPixClient {
    pixClient = newPixClient;
}

@end
