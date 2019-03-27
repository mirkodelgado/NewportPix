//
//  WriteDamageInfo.h
//  Newport Pix
//
//  Created by Mirko Delgado on 09/18/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

@interface WriteDamageInfo : NSObject {
    
    NSString *callNumber;
    NSString *equipmentID;
    NSString *relatedID;
    
    NSString *photoCount;
    
    NSString *row1;
    NSString *row2;
    NSString *row3;
    NSString *row4;
    NSString *row5;
    NSString *row6;
}

- (WriteDamageInfo*) getInstance;

-(void) setDmgInfo: (NSString *) call : (NSString *) unitID : (NSString *) relID : (NSString *) pCount : (BOOL) proRepair;

-(void) setRows: (NSArray *) rows;

-(void) createFile;

@end

