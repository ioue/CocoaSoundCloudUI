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

#import <QuartzCore/QuartzCore.h>

#import "OHAttributedLabel.h"

#import "NSAttributedString+Attributes.h"
#import "QuartzCore+SoundCloudAPI.h"
#import "UIImage+SoundCloudAPI.h"
#import "UIDevie+SoundCloudUI.h"

#import "SCBundle.h"

#import "SCRecordingUploadProgressView.h"

@interface SCGradientView : UIView
@end
@implementation SCGradientView
+ (Class)layerClass; { return [CAGradientLayer class]; }
@end


@interface SCRecordingUploadProgressView ()
- (void)commonAwake;

@property (nonatomic, readwrite, assign) UIImageView *artwork;
@property (nonatomic, readwrite, assign) UILabel *title;
@property (nonatomic, readwrite, assign) UIProgressView *progress;

@property (nonatomic, readwrite, assign) UIView *contentView;

@property (nonatomic, readwrite, assign) UIView *firstSeparator;
@property (nonatomic, readwrite, assign) UIView *secondSeparator;

@property (nonatomic, readwrite, assign) UILabel *progressLabel;

@property (nonatomic, readwrite, assign) OHAttributedLabel *resultText;
@property (nonatomic, readwrite, assign) UIImageView *resultImage;

@property (nonatomic, readwrite, assign) UIButton *openAppStoreButton;
@property (nonatomic, readwrite, assign) UIButton *openAppButton;


#pragma mark Actions
- (IBAction)openAppStore:(id)sender;
- (IBAction)openApp:(id)sender;

#pragma mark Notification Handling
- (void)applicationWillEnterForeground:(NSNotification *)aNotification;

#pragma mark Helpers
- (NSURL *)appURL;

@end

@implementation SCRecordingUploadProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonAwake];
    }
    return self;
}

- (void)commonAwake;
{
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    // Proggress State
    self.state = SCRecordingUploadProgressViewStateUploading;
    
    // Background Color
    self.backgroundColor = [UIColor clearColor];
    
    // Scrolling Behaviour
    self.alwaysBounceVertical = NO;
    
    if ([UIDevice isIPad]) {
        self.contentInset = UIEdgeInsetsMake(48, 44, 64, 44);
    } else {
        self.contentInset = UIEdgeInsetsMake(24, 22, 32, 22);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark Accessors

@synthesize artwork;
@synthesize title;
@synthesize progress;
@synthesize state;
@synthesize trackInfo;

@synthesize contentView;

@synthesize firstSeparator;
@synthesize secondSeparator;

@synthesize progressLabel;

@synthesize resultText;
@synthesize resultImage;

@synthesize openAppStoreButton;
@synthesize openAppButton;


- (UIImageView *)artwork;
{
    if (!artwork) {
        CGRect artworkFrame = CGRectZero;
        if ([UIDevice isIPad]) {
            artworkFrame = CGRectMake(0, 0, 80, 80);
        } else {
            artworkFrame = CGRectMake(0, 0, 40, 40);
        }
        artwork = [[[UIImageView alloc] initWithFrame:artworkFrame] autorelease];
        [self.contentView addSubview:artwork];
    }
    return artwork;
}

- (UILabel *)title;
{
    if (!title) {
        title = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        title.backgroundColor = [UIColor clearColor];
        title.numberOfLines = 2;
        title.lineBreakMode = UILineBreakModeWordWrap;
        title.text = nil;
        title.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        [self.contentView addSubview:title];
    }
    return title;
}

- (UIProgressView *)progress;
{
    if (!progress) {
        progress = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault] autorelease];
        progress.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:progress];
    }
    return progress;
}

- (UIView *)contentView;
{
    if (!contentView) {
        contentView = [[[SCGradientView alloc] initWithFrame:CGRectZero] autorelease];
        
        // Background Color
        contentView.backgroundColor = [UIColor whiteColor];
        
        // Shadow
        contentView.layer.shadowOffset = CGSizeMake(3, 5);
        contentView.layer.shadowRadius = 5;
        contentView.layer.shadowOpacity = 0.8;
        
        // Rounded Corners
        contentView.layer.cornerRadius = 8.0f;
        
        // Gradient
        ((CAGradientLayer *)contentView.layer).colors = [NSArray arrayWithObjects:
                                                         (id)[[UIColor whiteColor] CGColor],
                                                         (id)[[UIColor colorWithWhite:0.95 alpha:1.000] CGColor],
                                                         nil];
        
        [self addSubview:contentView];
    }
    return contentView;
}

- (UIView *)firstSeparator;
{
    if (!firstSeparator) {
        firstSeparator = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        firstSeparator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [self.contentView addSubview:firstSeparator];
    }
    return firstSeparator;
}

- (UIView *)secondSeparator;
{
    if (!secondSeparator) {
        secondSeparator = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        secondSeparator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [self.contentView addSubview:secondSeparator];
    }
    return secondSeparator;
}

- (UILabel *)progressLabel;
{
    if (!progressLabel) {
        progressLabel = [[[UILabel alloc] init] autorelease];
        progressLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        progressLabel.text = SCLocalizedString(@"record_save_uploading", @"Uploading ...");
        progressLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:progressLabel];
    }
    return progressLabel;
}

- (UIImageView *)resultImage;
{
    if (!resultImage) {
        resultImage = [[UIImageView alloc] init];
        [self.contentView addSubview:resultImage];
    }
    return resultImage;
}

- (OHAttributedLabel *)resultText;
{
    if (!resultText) {
        resultText = [[[OHAttributedLabel alloc] initWithFrame:CGRectZero] autorelease];
        resultText.backgroundColor = [UIColor clearColor];
        resultText.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:resultText];
    }
    return resultText;
}

- (UIButton *)openAppButton;
{
    if (!openAppButton) {
        openAppButton = [UIButton buttonWithType:UIButtonTypeCustom];
        openAppButton.backgroundColor = [UIColor clearColor];
        [openAppButton setBackgroundImage:[[SCBundle imageWithName:@"open-bg"] stretchableImageWithLeftCapWidth:14 topCapHeight:0] forState:UIControlStateNormal];
        [openAppButton setTitle:@"Open SoundCloud" forState:UIControlStateNormal];
        [openAppButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        openAppButton.titleLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        openAppButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10); 
        [openAppButton addTarget:self
                            action:@selector(openApp:)
                  forControlEvents:UIControlEventTouchUpInside];
        [openAppButton sizeToFit];
        openAppButton.frame = CGRectMake(0, 0, openAppButton.frame.size.width + 20, openAppButton.frame.size.height);
        [self.contentView addSubview:openAppButton];
    }
    return openAppButton;
}

- (UIButton *)openAppStoreButton;
{
    if (!openAppStoreButton) {
        openAppStoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        openAppStoreButton.backgroundColor = [UIColor clearColor];
        [openAppStoreButton setImage:[SCBundle imageWithName:@"appstore"]
                            forState:UIControlStateNormal];
        [openAppStoreButton addTarget:self action:@selector(openAppStore:) forControlEvents:UIControlEventTouchUpInside];
        [openAppStoreButton sizeToFit];
        [self.contentView addSubview:openAppStoreButton];
    }
    return openAppStoreButton;
}


#pragma mark View Management

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    CGFloat horizontalMargin = 12;
    if ([UIDevice isIPad]) {
        horizontalMargin = 24;
    }
    
    CGFloat verticalMargin = 16;
    if ([UIDevice isIPad]) {
        verticalMargin = 24;
    }
    
    CGFloat horizontalPadding = 10;
    if ([UIDevice isIPad]) {
        horizontalPadding = 18;
    }
    
    CGSize newContentSize = CGSizeZero;
    newContentSize.width = self.bounds.size.width - self.contentInset.left - self.contentInset.right;
    CGFloat innerWitdh = newContentSize.width - 2 * horizontalMargin;
    CGPoint offset = CGPointMake(horizontalMargin, verticalMargin);
    
    if (self.artwork.image) {
        self.artwork.frame = CGRectMake(offset.x,
                                        offset.y,
                                        CGRectGetWidth(self.artwork.frame),
                                        CGRectGetHeight(self.artwork.frame));
        
        offset.x += CGRectGetWidth(self.artwork.frame) + horizontalPadding;
    }
    
    
    if (self.title.text) {
        CGFloat maxTitleHeight = 0;
        if ([UIDevice isIPad]) {
            maxTitleHeight = 80;
        } else {
            maxTitleHeight = 40;
        }
        CGSize maxTitleSize = CGSizeMake(innerWitdh - offset.x, CGFLOAT_MAX);
        CGSize titleSize = [self.title.text sizeWithFont:self.title.font constrainedToSize:maxTitleSize];
        self.title.frame = CGRectMake(offset.x,
                                      offset.y,
                                      titleSize.width,
                                      titleSize.height);
        offset.x = horizontalMargin;
        if (self.artwork.image) {
            offset.y = CGRectGetMaxY(self.artwork.frame);
        } else {
            offset.y = CGRectGetMaxY(self.title.frame);
        }
        offset.y += 12;
    }
    
    self.firstSeparator.frame = CGRectMake(offset.x, offset.y, innerWitdh, 1);
    offset.y += 1;
    
    switch (self.state) {
        case SCRecordingUploadProgressViewStateFailed:
        {
            self.progress.hidden = YES;
            self.secondSeparator.hidden = NO;
            self.resultImage.hidden = NO;
            self.openAppButton.hidden = YES;
            self.openAppStoreButton.hidden = YES;
            
            offset.y += 12;
            
            self.progressLabel.text = SCLocalizedString(@"record_save_upload_fail", @"Ok, that went wrong.");
            [self.progressLabel sizeToFit];
            
            self.progressLabel.frame = CGRectMake(offset.x,
                                                  offset.y,
                                                  innerWitdh,
                                                  CGRectGetHeight(self.progressLabel.frame));
            
            offset.y += CGRectGetHeight(self.progressLabel.frame) + 18;
            self.secondSeparator.frame = CGRectMake(offset.x, offset.y, innerWitdh, 1);
            offset.y += 1;
            
            if ([UIDevice isIPad]) {
                offset.y += 16;
            } else {
                offset.y += 8;
            }
            
            self.resultImage.image = [SCBundle imageWithName:@"fail"];
            [self.resultImage sizeToFit];
            self.resultImage.frame = CGRectMake(newContentSize.width / 2.0 - CGRectGetWidth(self.resultImage.frame) / 2.0,
                                                offset.y,
                                                CGRectGetWidth(self.resultImage.frame),
                                                CGRectGetHeight(self.resultImage.frame));
            offset.y += CGRectGetHeight(self.resultImage.frame);
            
            break;
        }
        
        case SCRecordingUploadProgressViewStateSuccess:
        {
            self.progress.hidden = YES;
            self.secondSeparator.hidden = NO;
            self.resultImage.hidden = NO;
            
            offset.y += 12;
            
            self.progressLabel.text = SCLocalizedString(@"record_save_upload_success", @"Yay, that worked!");
            [self.progressLabel sizeToFit];
            
            self.progressLabel.frame = CGRectMake(offset.x,
                                                  offset.y,
                                                  innerWitdh,
                                                  CGRectGetHeight(self.progressLabel.frame));
            
            offset.y += CGRectGetHeight(self.progressLabel.frame) + 18;
            self.secondSeparator.frame = CGRectMake(offset.x, offset.y, innerWitdh, 1);
            offset.y += 1;
            
            if ([UIDevice isIPad]) {
                offset.y += 16;
            } else {
                offset.y += 8;
            }
            
            self.resultImage.image = [SCBundle imageWithName:@"iphone"];
            [self.resultImage sizeToFit];
            self.resultImage.frame = CGRectMake(offset.x + 6,
                                                offset.y,
                                                CGRectGetWidth(self.resultImage.frame),
                                                CGRectGetHeight(self.resultImage.frame));
            
            offset.y += CGRectGetHeight(self.resultImage.frame);
            
            if ([self appURL]) {
                self.openAppButton.hidden = NO;
                self.openAppStoreButton.hidden = YES;
                
                NSMutableAttributedString *text = [NSMutableAttributedString attributedStringWithString:@"See who's commenting on your sounds by opening it in the SoundCloud app."];
                [text setFont:self.resultText.font];
                self.resultText.attributedText = text;
                
                self.resultText.frame = CGRectMake(CGRectGetMaxX(self.resultImage.frame) + 10,
                                                   CGRectGetMinY(self.resultImage.frame) + 6,
                                                   innerWitdh - 3 - CGRectGetWidth(self.resultImage.frame) - 10,
                                                   CGRectGetHeight(self.resultImage.frame) - 12 - CGRectGetHeight(self.openAppButton.frame));
                
                self.openAppButton.frame = CGRectMake(CGRectGetMaxX(self.resultImage.frame) + 10,
                                                      CGRectGetMaxY(self.resultImage.frame) - CGRectGetHeight(self.openAppButton.frame) - 3,
                                                      CGRectGetWidth(self.openAppButton.frame),
                                                      CGRectGetHeight(self.openAppButton.frame));
                
                offset.x = horizontalMargin;
                offset.y = CGRectGetMaxY(self.openAppButton.frame);
                
            } else {
                self.openAppButton.hidden = YES;
                self.openAppStoreButton.hidden = NO;
                
                NSMutableAttributedString *text = [NSMutableAttributedString attributedStringWithString:@"See who's commenting on your sounds by downloading the free SoundCloud app."];
                NSRange orangeRange;
                orangeRange.location = 55;
                orangeRange.length = 4;
                [text setTextColor:[UIColor orangeColor] range:orangeRange];
                [text setFont:self.resultText.font];
                self.resultText.attributedText = text;
                
                self.resultText.frame = CGRectMake(CGRectGetMaxX(self.resultImage.frame) + 10,
                                                   CGRectGetMinY(self.resultImage.frame) + 6,
                                                   innerWitdh - 3 - CGRectGetWidth(self.resultImage.frame) - 10,
                                                   CGRectGetHeight(self.resultImage.frame) - 12 - CGRectGetHeight(self.openAppStoreButton.frame));
                
                self.openAppStoreButton.frame = CGRectMake(CGRectGetMaxX(self.resultImage.frame) + 10,
                                                      CGRectGetMaxY(self.resultImage.frame) - CGRectGetHeight(self.openAppStoreButton.frame) - 3,
                                                      CGRectGetWidth(self.openAppStoreButton.frame),
                                                      CGRectGetHeight(self.openAppStoreButton.frame));
                
                offset.x = horizontalMargin;
                offset.y = CGRectGetMaxY(self.openAppStoreButton.frame);
            }
            break;
        }
        
        default:
        {
            self.openAppButton.hidden = YES;
            self.openAppStoreButton.hidden = YES;
            self.secondSeparator.hidden = YES;
            self.resultImage.hidden = YES;
            self.progress.hidden = NO;
            
            offset.y += 12;

            self.progressLabel.text = SCLocalizedString(@"record_save_uploading", @"Uploading ...");
            [self.progressLabel sizeToFit];
            
            self.progressLabel.frame = CGRectMake(offset.x,
                                                  offset.y,
                                                  innerWitdh,
                                                  CGRectGetHeight(self.progressLabel.frame));
            
            offset.y += CGRectGetHeight(self.progressLabel.frame) + 6;
            

            [self.progress sizeToFit];
            self.progress.frame = CGRectMake(offset.x,
                                             offset.y,
                                             innerWitdh,
                                             CGRectGetHeight(self.progress.frame));
            
            offset.y += CGRectGetHeight(self.progress.frame);
            
            break;
        }
    }
    
    newContentSize.height += offset.y + verticalMargin;
    
    // Update Content Size and View
    self.contentSize = newContentSize;
    self.contentView.frame = CGRectMake(0,
                                        0,
                                        self.contentSize.width,
                                        self.contentSize.height);
}

#pragma mark Actions

- (IBAction)openAppStore:(id)sender;
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/apps/SoundCloud"]];
}

- (IBAction)openApp:(id)sender;
{
    NSURL *appURL = [self appURL];
    if (appURL) {
        [[UIApplication sharedApplication] openURL:appURL];
    }
}


#pragma mark Notification Handling

- (void)applicationWillEnterForeground:(NSNotification *)aNotification;
{
    [self setNeedsLayout];
}


#pragma mark Helpers

- (NSURL *)appURL;
{
    NSURL *trackURL = [NSURL URLWithString:[NSString stringWithFormat:@"soundcloud:tracks/%@", [trackInfo objectForKey:@"id"]]];
    NSURL *legacyTrackURL = [NSURL URLWithString:@"x-soundcloud:"];
    
    if ([[UIApplication sharedApplication] canOpenURL:trackURL]) {
        return trackURL;
    } else if ([[UIApplication sharedApplication] canOpenURL:legacyTrackURL]) {
        return legacyTrackURL;
    } else {
        return nil;
    }
}

@end


