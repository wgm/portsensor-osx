//
//  ServerModel.m
//  PortSensor
//
//  Created by Jeff Standen on 12/6/08.
//  Copyright 2008 WebGroup Media, LLC.. All rights reserved.
//

#import "ServerModel.h"

@implementation ServerModel
@synthesize title, sensors, numOK, numWarning, numCritical;

-(id)init {
	[super init];
	
	if(nil != self) {
		self.title = @"Server";
		self.sensors = [[NSMutableArray alloc] init];
		self.numOK = [NSNumber numberWithInt:0];
		self.numWarning = [NSNumber numberWithInt:0];
		self.numCritical = [NSNumber numberWithInt:0];
	}
	
	return self;
}

-(void)dealloc {
	[self.title release];
	//[self.sensors release];
	[self.numOK release];
	[self.numWarning release];
	[self.numCritical release];
	[super dealloc];
}

@end
