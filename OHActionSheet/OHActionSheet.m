//
//  UIActionSheetEx.m
//  AliSoftware
//
//  Created by Olivier on 23/01/11.
//  Copyright 2011 AliSoftware. All rights reserved.
//

#import "OHActionSheet.h"

@interface OHActionSheet () <UIActionSheetDelegate> @end



@implementation OHActionSheet
@synthesize buttonHandler = _buttonHandler;

/////////////////////////////////////////////////////////////////////////////
#pragma mark - Constructors

+(void)showFromView:(UIView*)view
              title:(NSString*)title
  cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
  otherButtonTitles:(NSArray *)otherButtonTitles
         completion:(OHActionSheetButtonHandler)completionBlock
{
    OHActionSheet* sheet = [[self alloc] initWithTitle:title
                                     cancelButtonTitle:cancelButtonTitle
                                destructiveButtonTitle:destructiveButtonTitle
                                     otherButtonTitles:otherButtonTitles
                                            completion:completionBlock];
    [sheet showFromView:view];
#if ! __has_feature(objc_arc)
    [sheet autorelease];
#endif
}

- (id)initWithTitle:(NSString*)title
  cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
  otherButtonTitles:(NSArray *)otherButtonTitles
         completion:(OHActionSheetButtonHandler)completionBlock;
{
    // Note: need to send at least the first button because if the otherButtonTitles parameter is nil, self.firstOtherButtonIndex will be -1
    NSString* firstOther = (otherButtonTitles && ([otherButtonTitles count]>0)) ? [otherButtonTitles objectAtIndex:0] : nil;
    self = [super initWithTitle:title delegate:self
              cancelButtonTitle:nil
         destructiveButtonTitle:destructiveButtonTitle
              otherButtonTitles:firstOther,nil];
    if (self != nil) {
        for(NSInteger idx = 1; idx<[otherButtonTitles count];++idx) {
            [self addButtonWithTitle: [otherButtonTitles objectAtIndex:idx] ];
        }
        
        // added this because sometimes an actionSheet was being created with an empty cancel button
        if (cancelButtonTitle) {
            [self addButtonWithTitle:cancelButtonTitle];
            self.cancelButtonIndex = self.numberOfButtons - 1;
        }
        
        self.buttonHandler = completionBlock;
    }
    return self;
}


-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.buttonHandler) {
        self.buttonHandler(self,buttonIndex);
#if ! __has_feature(objc_arc)
        [_buttonHandler release];
#endif
        self.buttonHandler = nil;
    }
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods

-(void)showFromView:(UIView *)view
{
    if ([view isKindOfClass:[UITabBar class]]) {
        [self showFromTabBar:(UITabBar*)view];
    } else if ([view isKindOfClass:[UIToolbar class]]) {
        [self showFromToolbar:(UIToolbar*)view];
    } else if ([view isKindOfClass:[UIBarButtonItem class]]) {
        [self showFromBarButtonItem:(UIBarButtonItem *)view animated:YES];
    } else {
        [super showFromRect:view.frame inView:view.superview animated:YES];
    }
}

-(void)showFromView:(UIView*)view withTimeout:(unsigned long)timeoutInSeconds timeoutButtonIndex:(NSInteger)timeoutButtonIndex
{
    [self showFromView:view withTimeout:timeoutInSeconds timeoutButtonIndex:timeoutButtonIndex timeoutMessageFormat:@"(Dismissed in %lus)"];
}

-(void)showFromView:(UIView*)view withTimeout:(unsigned long)timeoutInSeconds
timeoutButtonIndex:(NSInteger)timeoutButtonIndex timeoutMessageFormat:(NSString*)countDownMessageFormat
{
    __block dispatch_source_t timer = nil;
    __block long countDown = (signed long)timeoutInSeconds;
    
    // Add some timer sugar to the completion handler
    dispatch_block_t cancelTimer = ^{
        if (!timer) return;
        dispatch_source_cancel(timer);
#if ! __has_feature(objc_arc)
        dispatch_release(timer);
#endif
        timer = nil;
    };
    OHActionSheetButtonHandler finalHandler = [self.buttonHandler copy];
    self.buttonHandler = ^(OHActionSheet* bhSheet, NSInteger bhButtonIndex)
    {
        cancelTimer();
        finalHandler(bhSheet, bhButtonIndex);
    };
#if ! __has_feature(objc_arc)
    [finalHandler release];
#endif
    
    NSString* baseMessage = self.title;
    dispatch_block_t updateMessage = countDownMessageFormat ? ^{
        self.title = [NSString stringWithFormat:@"%@\n\n%@", baseMessage, [NSString stringWithFormat:countDownMessageFormat, countDown]];
    } : ^{ /* NOOP */ };
    updateMessage();
    
    // Schedule timer every second to update message. When timer reach zero, dismiss the alert
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), 1*NSEC_PER_SEC, 0.1*NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        --countDown;
        updateMessage();
        if (countDown <= 0)
        {
            [self dismissWithClickedButtonIndex:timeoutButtonIndex animated:YES];
            cancelTimer();
        }
    });
    
    // Show the alert and start the timer now
    [self showFromView:view];
    
    dispatch_resume(timer);
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - Memory Mgmt


#if ! __has_feature(objc_arc)
- (void)dealloc {
    [_buttonHandler release];
    [super dealloc];
}
#endif

@end
