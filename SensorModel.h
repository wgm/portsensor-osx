//
//  SensorModel.h
//  PortSensor
//
//  Created by Jeff Standen on 12/3/08.
//  Copyright 2008 WebGroup Media, LLC.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SensorModel : NSObject {
	NSString *title;
	NSString *status;
	NSString *lastRan;
	NSString *change;
	NSString *output;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *lastRan;
@property (nonatomic, retain) NSString *change;
@property (nonatomic, retain) NSString *output;
@end
