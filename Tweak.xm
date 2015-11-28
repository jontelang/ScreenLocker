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
// Static instances
//
static ScreenLockerWindow* SL;


//
// ScreenLockerWindow implementation 
//
@implementation ScreenLockerWindow

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName
{
	if( self.hidden )
	{
		if( [listenerName isEqualToString:@"com.jontelang.screenlocker.invisible"] ){
			SL.layer.borderWidth = 0;
		}else{
			SL.layer.borderWidth = 4;
		}
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
		if( [[[alertView textFieldAtIndex:0] text] length] > 0 ){
			pin = [[alertView textFieldAtIndex:0] text];
			[pin retain];
		}
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
// Creates the actual Activator listener object
//
static void createListener()
{
    if( [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0f ){
        SL = [[ScreenLockerWindow alloc] init];
    }else{
        SL = [[ScreenLockerWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    
	[SL setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.05]];
	[SL setWindowLevel:UIWindowLevelStatusBar+250];
	SL.layer.borderColor      = [[UIColor redColor] colorWithAlphaComponent:0.25f].CGColor;
	SL.userInteractionEnabled = YES;
    SL.exclusiveTouch         = YES;
	[[LAActivator sharedInstance] registerListener:SL forName:@"com.jontelang.screenlocker"];
	[[LAActivator sharedInstance] registerListener:SL forName:@"com.jontelang.screenlocker.invisible"];

	// No hardware buttons needed.
    UILongPressGestureRecognizer *hold = 
			[[UILongPressGestureRecognizer alloc] initWithTarget:SL 
			                   action:@selector(longHold:)];
	hold.minimumPressDuration = 3;
	hold.numberOfTouchesRequired = 2;
    [SL addGestureRecognizer:hold];
}


//
// Constructor
//
%ctor
{
	CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, (CFNotificationCallback)createListener, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorCoalesce); 
}