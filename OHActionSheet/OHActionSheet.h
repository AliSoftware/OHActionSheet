//
//  UIActionSheetEx.h
//  AliSoftware
//
//  Created by Olivier on 23/01/11.
//  Copyright 2011 AliSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OHActionSheet : UIActionSheet

typedef void (^OHActionSheetButtonHandler)(OHActionSheet* sheet,NSInteger buttonIndex);
@property (nonatomic, copy) OHActionSheetButtonHandler buttonHandler;

/////////////////////////////////////////////////////////////////////////////

+(void)showFromView:(UIView*)view
              title:(NSString*)title
	 cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
	 otherButtonTitles:(NSArray *)otherButtonTitles
         completion:(OHActionSheetButtonHandler)completionBlock;

- (id)initWithTitle:(NSString*)title
  cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
  otherButtonTitles:(NSArray *)otherButtonTitles
		 completion:(OHActionSheetButtonHandler)completionBlock;

/////////////////////////////////////////////////////////////////////////////

-(void)showFromView:(UIView*)view;

/**
 * Show the ActionSheet that will dismiss after timeoutInSeconds seconds, by simulating a tap on the timeoutButtonIndex button after this delay.
 *
 * This method uses the @"(Dismissed in %lus)" timeout message format by default.
 */
-(void)showFromView:(UIView*)view withTimeout:(unsigned long)timeoutInSeconds timeoutButtonIndex:(NSInteger)timeoutButtonIndex;

/**
 * Show the ActionSheet that will dismiss after timeoutInSeconds seconds, by simulating a tap on the timeoutButtonIndex button after this delay.
 *
 * The countDownMessageFormat is a string containing a %lu placeholder to customize the countdown message displayed in the ActionSheet.
 * If countDownMessageFormat is nil, no countdown message is added to the sheet title.
 */
-(void)showFromView:(UIView*)view withTimeout:(unsigned long)timeoutInSeconds
timeoutButtonIndex:(NSInteger)timeoutButtonIndex timeoutMessageFormat:(NSString*)countDownMessageFormat;

@end
