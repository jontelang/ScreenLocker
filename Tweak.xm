

//
// Defines
//
#define tag_setting_pin 1

//
// Includes
//
#import "Activator/libactivator.h"


//
// ScreenLockerWindow interface
//
@interface ScreenLockerWindow : UIWindow <LAListener,UIAlertViewDelegate>
{
	NSString *pin;
}
@end


//
// ScreenLockerWindow implementation 
//
@implementation ScreenLockerWindow

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	if( self.hidden )
	{
		[self makeKeyAndVisible];
		[event setHandled:YES];
	}
	else
	{
		// If we don't have a pin we're unlocked
		if( pin == Nil )
		{
			[self setHidden:YES];
		}
		// If we do, show the unlocker alert
		else
		{
			[self showAlertViewForUnlocking];
		}
		[event setHandled:YES];	
	}
}

-(void)longHold:(UILongPressGestureRecognizer*)rec
{
	if( rec.state == UIGestureRecognizerStateBegan )
	{
		// This means it is unlocked.
		if( pin == Nil )
		{
			[self showAlertViewForLocking];
		}
		// Locked! Let's try to unlock.
		else
		{
			[self showAlertViewForUnlocking];
		}
	}
}

-(void)showAlertViewForUnlocking
{
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Unlock screen" 
		   						message:@"Enter the password"
		   				       delegate:self 
		   			  cancelButtonTitle:@"Unlock" 
		   			  otherButtonTitles:nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alert show];
}

-(void)showAlertViewForLocking
{
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Lock screen" 
		   						message:@"Enter some password"
		   				       delegate:self 
		   			  cancelButtonTitle:@"Lock" 
		   			  otherButtonTitles:nil];
	alert.tag = tag_setting_pin;
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if( alertView.tag == tag_setting_pin )
	{
		pin = [[alertView textFieldAtIndex:0] text];
		[pin retain];
	}
	// We're not setting the pin, so we must be unlocking
	else
	{
		if( [pin isEqual:[[alertView textFieldAtIndex:0] text]] )
		{
			pin = Nil;
			[self setHidden:YES];
		}
	}
}

@end


//
// Static instances
//
static ScreenLockerWindow* SL;


//
// Creates the actual Activator listener object
//
static void createListener()
{
	SL = [[ScreenLockerWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[SL setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.05]];
	[SL setWindowLevel:UIWindowLevelStatusBar+250];
	SL.layer.borderWidth      = 4;
	SL.layer.borderColor      = [[UIColor redColor] colorWithAlphaComponent:0.25f].CGColor;
	SL.userInteractionEnabled = YES;
    SL.exclusiveTouch         = YES;
	[[LAActivator sharedInstance] registerListener:SL forName:@"com.jontelang.screenlocker"];

	// No hardware buttons needed.
    UILongPressGestureRecognizer *hold = 
			[[UILongPressGestureRecognizer alloc] initWithTarget:SL 
			                   action:@selector(longHold:)];
    [SL addGestureRecognizer:hold];
}


//
// Constructor
//
%ctor
{
	CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, (CFNotificationCallback)createListener, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorCoalesce); 
}