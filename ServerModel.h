//
//  ServerModel.h
//  PortSensor
//
//  Created by Jeff Standen on 12/6/08.
//  Copyright 2008 WebGroup Media, LLC.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ServerModel : NSObject {
	NSString *title;
	NSMutableArray *sensors;
	NSNumber *numOK;
	NSNumber *numWarning;
	NSNumber *numCritical;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSMutableArray *sensors;
@property (nonatomic, retain) NSNumber *numOK;
@property (nonatomic, retain) NSNumber *numWarning;
@property (nonatomic, retain) NSNumber *numCritical;

@end
