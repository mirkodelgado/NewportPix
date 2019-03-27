//
//  NetworkUtil.h
//  Newport Pix
//
//  Created by Mirko Delgado on 08/12/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "NetworkUtil.h"

static NSUInteger count = 0;

@implementation NetworkUtil

+(void)showNWActivityIndicator{
	
	++count;
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

+(void)hideNWActivityIndicator{
	
	--count;
    
	if(count == 0){
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

@end
