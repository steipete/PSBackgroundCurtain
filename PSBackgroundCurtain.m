//
//  PSBackgroundCurtain.m
//
//  Created by Peter Steinberger on 07.01.11.
//  Copyright 2011 Peter Steinberger. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "PSBackgroundCurtain.h"
#import <QuartzCore/QuartzCore.h>

@interface PSBackgroundCurtain ()
@property (nonatomic, retain) UIView *curtainView;
@end

#define kCurtainAnimationDuration 0.5f

@implementation PSBackgroundCurtain

@synthesize backgroundWatchEnabled = backgroundWatchEnabled_;
@synthesize curtainView = curtainView_;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark private

- (void)applicationWillResignActive:(NSNotification *)notification {
  // we're still visible, so just dim!
  [self setCurtainRaised:YES animated:YES alpha:0.5];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
  // un-dim animated (app just was opened up)
  [self setCurtainRaised:NO animated:YES];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
  [self setCurtainRaised:YES animated:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject

- (id)init {
  if ((self = [super init])) {
    
    // most wanted default behavior
    self.backgroundWatchEnabled = YES;
    
    // listen for background notifications
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(applicationWillResignActive:)
                          name:UIApplicationWillResignActiveNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(applicationDidBecomeActive:)
                          name:UIApplicationDidBecomeActiveNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(applicationDidEnterBackground:)
                          name:UIApplicationDidEnterBackgroundNotification
                        object:nil];    
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [curtainView_ release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public

- (BOOL)isCurtainRaised {
  return self.curtainView != nil; 
}

- (void)setCurtainRaised:(BOOL)curtainRaised {
  [self setCurtainRaised:curtainRaised animated:NO alpha:1.0];
}

- (void)setCurtainRaised:(BOOL)curtainRaised animated:(BOOL)animated {
  [self setCurtainRaised:curtainRaised animated:animated alpha:1.0];
}

- (void)setCurtainRaised:(BOOL)curtainRaised animated:(BOOL)animated alpha:(double)alpha {
  if (curtainRaised) {
    if (![self isCurtainRaised]) {
      UIView *curtain = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
      curtain.backgroundColor = [UIColor blackColor];
      
      // find top window!
      UIWindow *visibleWindow = nil;
      NSArray *windows = [[UIApplication sharedApplication] windows];
      for (UIWindow *window in windows) {
        if (!window.hidden && !visibleWindow) {
          visibleWindow = window;
        }
        if ([window rootViewController]) {
          visibleWindow = window;
          break;
        }
      }
      [visibleWindow addSubview:curtain];
      
      if (animated) {
        curtain.alpha = 0.0;
        [UIView animateWithDuration:kCurtainAnimationDuration animations:^{
          curtain.alpha = alpha;
        }];
      }      
      self.curtainView = curtain;
    }else {
      // kill animation and finish it instantly!
      if (!animated) {
        [self.curtainView.layer removeAllAnimations];
        self.curtainView.alpha = alpha;
      }
    }
  }else {
    if ([self isCurtainRaised]) {    
      if (animated) {
        [UIView animateWithDuration:kCurtainAnimationDuration animations:^{
          self.curtainView.alpha = 0.0;
        } completion:^(BOOL finished){
          if (finished) {
            [self.curtainView removeFromSuperview];
            self.curtainView = nil;
          }
        }];
      }else {
        [self.curtainView removeFromSuperview];
        self.curtainView = nil;
      }
    }  
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Singleton

static PSBackgroundCurtain *sharedInstance = nil; 

+ (PSBackgroundCurtain *)sharedInstance {
  @synchronized(self) {
    if (sharedInstance == nil) {
      sharedInstance = [[self alloc] init];
    }
  }
  return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
  @synchronized(self) {
    if (sharedInstance == nil) {
      sharedInstance = [super allocWithZone:zone];
      return sharedInstance;
    }
  }
  return nil;
}

- (id)copyWithZone:(NSZone *)zone {
  return self;
}

- (id)retain {
  return self;
}

- (NSUInteger)retainCount {
  return NSUIntegerMax; \
}

- (void)release {
}

- (id)autorelease{
  return self;
}

@end
