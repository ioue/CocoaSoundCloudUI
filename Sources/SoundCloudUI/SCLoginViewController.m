/*
 * Copyright 2010, 2011 nxtbgthng for SoundCloud Ltd.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 *
 * For more information and documentation refer to
 * http://soundcloud.com/api
 * 
 */

#import "UIViewController+SoundCloudUI.h"
#import "UIView+SoundCloudUI.h"
#import "UIDevice+SoundCloudUI.h"

#import "SCLoginView.h"
#import "SCConnectToSoundCloudTitleView.h"
#import "NXOAuth2AccountStore.h"

#import "SCSoundCloud.h"
#import "SCSoundCloud+Private.h"
#import "SCConstants.h"
#import "SCBundle.h"

#import "SCUIErrors.h"

#import "SCLoginViewController.h"


#pragma mark -

@interface SCLoginViewController () <UIScrollViewDelegate, SCLoginViewProtocol>
- (id)initWithPreparedURL:(NSURL *)anURL completionHandler:(SCLoginViewControllerCompletionHandler)aCompletionHandler;

#pragma mark Accessors
@property (nonatomic, retain) NSURL *preparedURL;
@property (nonatomic, assign) SCLoginView *loginView;
@property (nonatomic, assign) SCConnectToSoundCloudTitleView *scTitleView;
@property (nonatomic, copy) SCLoginViewControllerCompletionHandler completionHandler;

#pragma mark Notifications
- (void)accountDidChange:(NSNotification *)aNotification;
- (void)failToRequestAccess:(NSNotification *)aNotification;

#pragma mark Action
- (void)cancel;
@end


@implementation SCLoginViewController


#pragma mark Class Methods

+ (id)loginViewControllerWithPreparedURL:(NSURL *)anURL completionHandler:(SCLoginViewControllerCompletionHandler)aCompletionHandler;
{
    
    SCLoginViewController *loginViewController = [[[self alloc] initWithPreparedURL:anURL completionHandler:aCompletionHandler] autorelease];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    
    return [navigationController autorelease];
}

#pragma mark Lifecycle

@synthesize preparedURL;
@synthesize loginView;
@synthesize completionHandler;

- (id)initWithPreparedURL:(NSURL *)anURL completionHandler:(SCLoginViewControllerCompletionHandler)aCompletionHandler;
{
    self = [super init];
    if (self) {
        preparedURL = [anURL retain];
        completionHandler = [aCompletionHandler copy];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accountDidChange:)
                                                     name:SCSoundCloudAccountDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(failToRequestAccess:)
                                                     name:SCSoundCloudDidFailToRequestAccessNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateScrollView)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateScrollView)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [preparedURL release];
    [completionHandler release];
    [super dealloc];
}


#pragma mark UIViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.loginView = [[[SCLoginView alloc] initWithFrame:self.view.bounds] autorelease];
    self.loginView.loginDelegate = self;
    self.loginView.delegate = self;
    self.loginView.contentSize = CGSizeMake(1, 480);
    [self.loginView removeAllCookies];
    [self.view addSubview:self.loginView];

    SCConnectToSoundCloudTitleView *scTitleView = [[[SCConnectToSoundCloudTitleView alloc] initWithFrame:[self titleFrame]] autorelease];
    [self.view addSubview:scTitleView];
    _scTitleView = scTitleView;

    // Navigation Bar
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
    if ([UIDevice isIPad]) {
        return YES;
    }

    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    _scTitleView.frame = [self titleFrame];
    self.loginView.frame = [self loginViewFrame];
}

- (CGRect)titleFrame
{
    const CGRect bounds = [self safeArea];
    return CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetWidth(bounds), 44.0);
}

- (CGRect)loginViewFrame
{
    const CGRect bounds = [self safeArea];
    const CGRect rect = [self titleFrame];
    return CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(rect), CGRectGetWidth(bounds), CGRectGetMaxY(bounds) - CGRectGetMaxY(rect));
}

- (CGRect)safeArea
{
#if ((TARGET_OS_SIMULATOR || TARGET_OS_IPHONE || TARGET_OS_TV) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000))  //  iOS11
    if (@available(iOS 11.0, *)) {
        return UIEdgeInsetsInsetRect(self.view.bounds, self.view.safeAreaInsets);
    }
#endif
    return self.view.bounds;
}

#pragma mark Notifications

- (void)accountDidChange:(NSNotification *)aNotification;
{
    if (self.completionHandler) {
        self.completionHandler(nil);
    }
    
    [[self modalPresentingViewController] dismissModalViewControllerAnimated:YES];
}

- (void)failToRequestAccess:(NSNotification *)aNotification;
{
    if (self.completionHandler) {
        NSError *error = [[aNotification userInfo] objectForKey:NXOAuth2AccountStoreErrorKey];
        self.completionHandler(error);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"auth_error", @"Auth Error")
                                                    message:SCLocalizedString(@"auth_error_message", @"Auth Message Error")
                                                   delegate:nil
                                          cancelButtonTitle:SCLocalizedString(@"alert_ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];

    //[[self modalPresentingViewController] dismissModalViewControllerAnimated:YES];
}

- (void)updateScrollView
{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ||
        ![UIDevice isTallIphone]) {
        UIView *firstResponderView = [self.loginView.credentialsView firstResponderFromSubviews];
        CGRect bounds;
        CGPoint position;
        // Our TextField requires a y-offset (self.loginView.frame.origin.y)
        if ([firstResponderView isKindOfClass:[UITextField class]]) {
            bounds = [firstResponderView convertRect:firstResponderView.superview.superview.bounds
                                              toView:self.view];
            position = CGPointMake(self.loginView.credentialsView.bounds.origin.x,
                                   bounds.origin.y - self.loginView.frame.origin.y);
        } else {
            position = self.view.bounds.origin;
        }

        [self.loginView setContentOffset:CGPointMake(position.x,
                                                     position.y)
                                animated:YES];
    }
}

#pragma mark Private

- (void)cancel;
{   
    if (self.completionHandler) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Canceled by user." forKey:NSLocalizedDescriptionKey];
        self.completionHandler([NSError errorWithDomain:SCUIErrorDomain code:SCUICanceledErrorCode userInfo:userInfo]);
    }
    
    [[self modalPresentingViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.loginView setNeedsDisplay];
}

@end
