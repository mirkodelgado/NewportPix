//
//  UserLocationsDao.h
//  Newport Pix
//
//  Created by Mirko Delgado on 08/20/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

#import "ResponseInfo.h"

@interface InfoDao : NSObject {

	sqlite3 *database;
}

-(id)initWithDataBase;

-(ResponseInfo *)getResponseInfo;

-(void)closeAll;

@end
