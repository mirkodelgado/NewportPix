//
//  SettingsDao.h
//  Newport Pix
//
//  Created by Mirko Delgado on 08/08/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface SettingsDao : NSObject {

	sqlite3 *database;
}

-(id)initWithDataBase;

-(NSUInteger)getDbVersion;
-(void)updateDbVersion:(NSUInteger) version;

-(NSArray *)getPixSettings;

-(void)closeAll;

-(NSUInteger)checkLoginRequired;
-(NSString *)getUserName;
-(void)updateWithLoginResponse:(NSString *)status : (NSString *)ownername;
-(NSString *)getOwnerName;

@end
