//
//  CallsDao.h
//  Newport Pix
//
//  Created by Mirko Delgado on 08/15/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface CallsDao : NSObject {

	sqlite3 *database;
}

-(id)initWithDataBase;

-(NSMutableArray *)getCallInfo;
-(NSArray *)getCallSummaryInfo: (NSString *) callNumber;

-(void)closeAll;

@end
