//
//  SQLiteLock.m
//  NewportPix
//
//  Created by Mirko Delgado on 08/08/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "SQLiteLock.h"

static NSLock *theLock;
static BOOL writeFlag;

static NSUInteger readCount = 0;

@implementation SQLiteLock

+(void) initialize {
	
	theLock = [[NSLock alloc] init];
}

+(id)getReadWriteLock:(BOOL)isWrite {
	
	/*if(isWrite){
		MELogAll(@"getting lock to write..");
	}else{
		MELogAll(@"getting lock to read..");
	}*/
	//(@"read process count b4 = %i", readCount);
	
	
	BOOL readFlagWithLock = NO;
	
	if(isWrite || writeFlag){
		BOOL b = NO;
		while(!b || readCount != 0){
			
			if(!b){b = [theLock tryLock];}
			//(@"The value of the bool is %@\n", (b ? @"YES" : @"NO"));
		}
		//MELog(@"Tout bool is %@\n", (b ? @"YES" : @"NO"));
		
		if(!isWrite){
			readFlagWithLock = YES;
			////(@"gotttt lock to read..");
		}else{
			writeFlag = YES;
			////(@"gotttt lock to write..");
		}
	}
	
	if(!isWrite){
				
		++readCount;
		if(readFlagWithLock){
			[theLock unlock];
		}
		////(@"read process count = %i", readCount);
	}
	
	return nil;
}

+(void)freeNotification:(BOOL)isWrite {
	
	//MELogAll(@"freeNotification..%@", (isWrite ? @"Write" : @"Read"));
	if(writeFlag){
		@try {
			[theLock unlock];
		}
		@catch (NSException * e) {
			//MELog(@"error: try to handle this lock error");
		}
		@finally {
			writeFlag = NO;
			
		}
	}else{
		if(readCount >0){
			--readCount;
		}
		//MELogAll(@"read process count = %i", readCount);
	}
}

//-(void)dealloc {           //mgd+080814 - New ios feature ARC - Auto Reference Counting .... not needed anymore
//	[theLock release];
//	[super dealloc];
//}

@end
