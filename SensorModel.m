//
//  SensorModel.m
//  PortSensor
//
//  Created by Jeff Standen on 12/3/08.
//  Copyright 2008 WebGroup Media, LLC.. All rights reserved.
//

#import "SensorModel.h"


@implementation SensorModel
@synthesize title, status, lastRan, change, output;

-(void)dealloc {
	[title release];
	[status release];
	[lastRan release];
	[change release];
	[output release];
	[super dealloc];
}

@end
