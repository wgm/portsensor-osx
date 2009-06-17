//
//  Header.m
//  PortSensor
//
//  Created by Jeff Standen on 12/5/08.
//  Copyright 2008 WebGroup Media, LLC.. All rights reserved.
//

#import "Header.h"


@implementation Header

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		gradient = [[[NSGradient alloc] initWithColorsAndLocations:
					 [NSColor colorWithDeviceRed:.102 green:.353 blue:.675 alpha:1], (CGFloat) 0.0,
					 [NSColor colorWithDeviceRed:.035 green:.114 blue:0.416 alpha:1],(CGFloat)1.0,
					 nil] retain];
		
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	[gradient drawInRect:rect angle:90.0];
}

-(void)dealloc {
	[gradient release];
	[super dealloc];
}

@end
