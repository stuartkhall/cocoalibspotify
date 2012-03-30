//
//  SPLoginLogicViewController.m
//  CocoaLibSpotify iOS Library
//
//  Created by Daniel Kennett on 24/03/2012.
/*
 Copyright (c) 2011, Spotify AB
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of Spotify AB nor the names of its contributors may 
 be used to endorse or promote products derived from this software 
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL SPOTIFY AB BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
 OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SPLoginLogicViewController.h"
#import "SPLoginViewControllerInternal.h"

@interface SPLoginLogicViewController()

-(void)switchViewToLoggingInState:(BOOL)isLoggingIn;
-(void)positionLoggingInView;

@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;
@property (retain, nonatomic) UIView *loggingInView;
@property (retain, nonatomic) UILabel *loginLabel;
@property (retain, nonatomic) UILabel *passwordLabel;
@property (retain, nonatomic) UIView *loginAreaSeparator;
@property (retain, nonatomic) UIImageView *backgroundImageView;

@property (retain, nonatomic) UIBarButtonItem *cancelButton;
@property (retain, nonatomic) UIBarButtonItem *loginButton;

@property (retain, nonatomic) IBOutlet UIView *loginFormView;

@end

@implementation SPLoginLogicViewController

@synthesize session;
@synthesize usernameField;
@synthesize passwordField;
@synthesize loggingInView;
@synthesize loginLabel;
@synthesize passwordLabel;
@synthesize loginAreaSeparator;
@synthesize backgroundImageView;
@synthesize loginFormView;
@synthesize allowsCancel;
@synthesize remembersCredentials;
@synthesize cancelButton;
@synthesize loginButton;

-(id)initWithSession:(SPSession *)sess {
	
	self = [super init];
	
	if (self) {
		self.session = sess;
		self.modalPresentationStyle = UIModalPresentationFormSheet;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(sessionDidFailToLogin:)
													 name:SPSessionLoginDidFailNotification
												   object:self.session];

		self.allowsCancel = YES;
		self.title = @"Spotify";
        self.remembersCredentials = YES;
		
		[self addObserver:self
			   forKeyPath:@"allowsCancel"
				  options:0
				  context:nil];
		
		[self addObserver:self
			   forKeyPath:@"allowsAutomaticLoginToggle"
				  options:0
				  context:nil];
	}
	
	return self;
}

-(NSString *)currentPage {
	return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"allowsCancel"]) {
		self.navigationItem.leftBarButtonItem = self.allowsCancel ? self.cancelButton : nil;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)positionLoggingInView {
	
	if (self.loggingInView != nil) {
		CGRect containerFrame = self.loginFormView.bounds;
		CGRect loggingInViewFrame = self.loggingInView.frame;
		loggingInViewFrame.origin.y = CGRectGetMidY(containerFrame) - (CGRectGetHeight(loggingInViewFrame) / 2);
		loggingInViewFrame.origin.x = CGRectGetMidX(containerFrame) - (CGRectGetWidth(loggingInViewFrame) / 2);
		self.loggingInView.frame = CGRectIntegral(loggingInViewFrame);
	}
}

- (IBAction)performLogin:(id)sender {
	
	if (self.usernameField.text.length == 0 || self.passwordField.text.length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed"
														message:@"Please enter your username and password."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[[alert autorelease] show];
		
		return;
	}
	
	[self.session attemptLoginWithUserName:self.usernameField.text
								  password:self.passwordField.text
					   rememberCredentials:self.remembersCredentials];
	
	[self switchViewToLoggingInState:YES];
	
}

- (IBAction)cancel:(id)sender {
	
	if ([self.parentViewController isKindOfClass:[SPLoginViewController class]]) {
		SPLoginViewController *controller = (SPLoginViewController *)self.parentViewController;
		[controller dismissLoginView:NO];
	}
}

-(void)sessionDidFailToLogin:(NSNotification *)notification {
	
	NSError *error = [[notification userInfo] valueForKey:SPSessionLoginDidFailErrorKey];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed"
													message:[error localizedDescription]
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[[alert autorelease] show];
	
	[self switchViewToLoggingInState:NO];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)loadView {
	
	NSURL *bundlePath = [[NSBundle mainBundle] URLForResource:@"SPLoginResources" withExtension:@"bundle"];
	NSBundle *resourcesBundle = [NSBundle bundleWithURL:bundlePath];
	
	self.view = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 416.0)] autorelease];
	self.view.backgroundColor = [UIColor redColor];

	self.backgroundImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 416.0)] autorelease];
	self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.backgroundImageView.backgroundColor = [UIColor blueColor];
	self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		self.backgroundImageView.image = [UIImage imageWithContentsOfFile:[resourcesBundle pathForResource:@"SPLoginViewBackground@2x" ofType:@"png"]];
	else
		self.backgroundImageView.image = [UIImage imageWithContentsOfFile:[resourcesBundle pathForResource:@"SPLoginViewBackground" ofType:@"png"]];
	
	[self.view addSubview:self.backgroundImageView];
	
	// Login form background
	
	UIView *loginContainerView = [[[UIView alloc] initWithFrame:CGRectMake(10.0, 20.0, 300.0, 185.0)] autorelease];
	loginContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[self.view addSubview:loginContainerView];
	
	UIImageView *blueRect = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 185.0)] autorelease];
	blueRect.contentMode = UIViewContentModeBottom;
	blueRect.image = [UIImage imageWithContentsOfFile:[resourcesBundle pathForResource:@"SPLoginViewFacebookBackground" ofType:@"png"]];
	[loginContainerView addSubview:blueRect];
	
	UIImageView *facebookIcon = [[[UIImageView alloc] initWithFrame:CGRectMake(30.0, 29.0, 22.0, 23.0)] autorelease];
	facebookIcon.contentMode = UIViewContentModeBottom;
	facebookIcon.image = [UIImage imageWithContentsOfFile:[resourcesBundle pathForResource:@"SPLoginViewFacebookIcon" ofType:@"png"]];
	[blueRect addSubview:facebookIcon];
	
	UILabel *loginHeader = [[[UILabel alloc] initWithFrame:CGRectMake(59.0, 30.0, 212.0, 21.0)] autorelease];
	loginHeader.text = @"Login with Facebook or Spotify";
	loginHeader.textColor = [UIColor whiteColor];
	loginHeader.font = [UIFont boldSystemFontOfSize:14.0];
	loginHeader.shadowColor = [UIColor colorWithWhite:0.2 alpha:1.0];
	loginHeader.shadowOffset = CGSizeMake(0.0, -1.0);
	loginHeader.backgroundColor = [UIColor clearColor];
	[blueRect addSubview:loginHeader];
	
	self.loginFormView = [[[UIView alloc] initWithFrame:CGRectMake(20.0, 77.0, 260.0, 87.0)] autorelease];
	[loginContainerView addSubview:self.loginFormView];
	
	UIImageView *textFieldBg = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 260.0, 87.0)] autorelease];
	textFieldBg.contentMode = UIViewContentModeBottom;
	textFieldBg.image = [UIImage imageWithContentsOfFile:[resourcesBundle pathForResource:@"SPLoginFormBackground" ofType:@"png"]];
	[self.loginFormView addSubview:textFieldBg];
	
	self.loginAreaSeparator = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 43.0, 260.0, 1.0)] autorelease];
	[self.loginAreaSeparator setBackgroundColor:[UIColor colorWithWhite:0.54 alpha:1.0]];
	[self.loginFormView addSubview:self.loginAreaSeparator];

	self.loginLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 12.0, 69.0, 21.0)] autorelease];
	self.loginLabel.text = @"Username";
	self.loginLabel.font = [UIFont boldSystemFontOfSize:14.0];
	[self.loginFormView addSubview:self.loginLabel];
	
	self.passwordLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12.0, 55.0, 69.0, 21.0)] autorelease];
	self.passwordLabel.text = @"Password";
	self.passwordLabel.font = [UIFont boldSystemFontOfSize:14.0];
	[self.loginFormView addSubview:self.passwordLabel];
	
	self.usernameField = [[[UITextField alloc] initWithFrame:CGRectMake(88.0, 10.0, 162.0, 26.0)] autorelease];
	self.usernameField.font = [UIFont systemFontOfSize:14.0];
	self.usernameField.placeholder = @"or Facebook email";
	self.usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	self.usernameField.delegate = self;
	self.usernameField.returnKeyType = UIReturnKeyNext;
	[self.loginFormView addSubview:self.usernameField];
	
	self.passwordField = [[[UITextField alloc] initWithFrame:CGRectMake(88.0, 52.0, 162.0, 26.0)] autorelease];
	self.passwordField.font = [UIFont systemFontOfSize:14.0];
	self.passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	self.passwordField.delegate = self;
	self.passwordField.secureTextEntry = YES;
	self.passwordField.returnKeyType = UIReturnKeyGo;
	[self.loginFormView addSubview:self.passwordField];
	
	self.loggingInView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 127.0, 49.0)];
	self.loggingInView.backgroundColor = [UIColor whiteColor];
	
	UILabel *loggingInLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 14.0, 127.0, 21.0)] autorelease];
	loggingInLabel.text = @"Logging in…";
	loggingInLabel.font = [UIFont systemFontOfSize:14.0];
	loggingInLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
	loggingInLabel.backgroundColor = [UIColor whiteColor];
	loggingInLabel.textAlignment = UITextAlignmentCenter;
	
	[self.loggingInView addSubview:loggingInLabel];
	[self.loginFormView addSubview:self.loggingInView];
	
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
														 style:UIBarButtonItemStylePlain
														target:self
														action:@selector(cancel:)];
    self.cancelButton.tintColor = [UIColor colorWithRed:0xED/255.0 green:0xEC/255.0 blue:0xE8/255.0 alpha:1];
	
	self.loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Log In"
														style:UIBarButtonItemStylePlain
													   target:self
													   action:@selector(performLogin:)];
    self.loginButton.tintColor = [UIColor colorWithRed:0xED/255.0 green:0xEC/255.0 blue:0xE8/255.0 alpha:1];
	
	self.navigationItem.leftBarButtonItem = self.allowsCancel ? self.cancelButton : nil;
	self.navigationItem.rightBarButtonItem = self.loginButton;
	[self positionLoggingInView];
	[self switchViewToLoggingInState:NO];
	self.usernameField.text = self.session.storedCredentialsUserName;
	
	[self.usernameField becomeFirstResponder];
}

-(void)switchViewToLoggingInState:(BOOL)isLoggingIn {
	
	self.usernameField.hidden = isLoggingIn;
	self.passwordField.hidden = isLoggingIn;
	self.loginLabel.hidden = isLoggingIn;
	self.passwordLabel.hidden = isLoggingIn;
	self.loginAreaSeparator.hidden = isLoggingIn;
	
	self.loggingInView.hidden = !isLoggingIn;
	
	if (isLoggingIn) {
		[self.usernameField resignFirstResponder];
		[self.passwordField resignFirstResponder];
	} else {
		[self.passwordField becomeFirstResponder];
	}
}

-(void)resetState {
	[self switchViewToLoggingInState:NO];
}

-(void)viewWillAppear:(BOOL)animated {
	previousStyle = [[UIApplication sharedApplication] statusBarStyle];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:previousStyle animated:animated];
}

- (void)viewDidUnload
{
	[self setUsernameField:nil];
	[self setPasswordField:nil];
	[self setLoggingInView:nil];
	[self setLoginLabel:nil];
	[self setPasswordLabel:nil];
	[self setLoginAreaSeparator:nil];
	[self setBackgroundImageView:nil];
	[self setLoginFormView:nil];
	[self setCancelButton:nil];
	[self setLoginButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	if (textField == self.usernameField) {
		[self.passwordField becomeFirstResponder];
		return NO;
	} else if (textField == self.passwordField) {
		[self performLogin:textField];
		[textField resignFirstResponder];
		return NO;
	}
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)dealloc {
	
	[self removeObserver:self forKeyPath:@"allowsAutomaticLoginToggle"];
	[self removeObserver:self forKeyPath:@"allowsCancel"];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:SPSessionLoginDidFailNotification
												  object:self.session];
	
	[session release];
	[usernameField release];
	[passwordField release];
	[loggingInView release];
	[loginLabel release];
	[passwordLabel release];
	[loginAreaSeparator release];
	[backgroundImageView release];
	[loginFormView release];
	[cancelButton release];
	[loginButton release];
	[super dealloc];
}

@end
