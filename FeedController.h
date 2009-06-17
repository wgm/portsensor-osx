#import <Cocoa/Cocoa.h>
#import <Growl/GrowlApplicationBridge.h>
#import "Header.h"

@interface FeedController : NSObject <GrowlApplicationBridgeDelegate> {
	IBOutlet NSOutlineView *treeView;
	IBOutlet NSTextField *statusOkLabel;
	IBOutlet NSTextField *statusWarnLabel;
	IBOutlet NSTextField *statusCriticalLabel;
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSToolbarItem *timerToolbarItem;
	IBOutlet NSImageView *headerImageView;
	
	NSTimer *feedTimer;
	NSMutableDictionary *serverMap;
	
	NSImage *ledGreenIcon;
	NSImage *ledYellowIcon;
	NSImage *ledRedIcon;
	NSImage *feedIcon;
	NSImage *serverIcon;
	
	NSDictionary *attrGreen;
	NSDictionary *attrYell;
	NSDictionary *attrRed;
	NSDictionary *attrBlack;
	NSDictionary *attrWhite;
}

- (IBAction)checkFeed:(id)sender;
- (IBAction)toggleTimer:(id)sender;
-(void) growlString:(NSString*)title description:(NSString*)description;
-(NSDictionary *) registrationDictionaryForGrowl;

@property (nonatomic,retain) NSMutableDictionary *serverMap;

@end

