//
//  MainViewController.m
//  OHAlertsExample
//
//  Created by Olivier Halligon on 02/07/2014.
//
//

#import "MainViewController.h"
#import "OHActionSheet.h"

@interface MainViewController ()
@property (nonatomic, retain) IBOutlet UILabel *status;
@end

@implementation MainViewController


-(IBAction)showSheet1:(UIButton*)sender
{
	NSArray* flavours = [NSArray arrayWithObjects:@"chocolate",@"vanilla",@"strawberry",nil];
	
    [OHActionSheet showFromView:sender
                          title:@"Ice cream?"
              cancelButtonTitle:@"Maybe later"
         destructiveButtonTitle:@"No thanks!"
              otherButtonTitles:flavours
                     completion:^(OHActionSheet *sheet, NSInteger buttonIndex)
     {
         NSLog(@"button tapped: %ld", (long)buttonIndex);
         if (buttonIndex == sheet.cancelButtonIndex) {
             self.status.text = @"Your order has been postponed";
         }
         else if (buttonIndex == sheet.destructiveButtonIndex)
         {
             self.status.text = @"Your order has been cancelled";
         }
         else
         {
             NSString* flavour = [flavours objectAtIndex:(buttonIndex-sheet.firstOtherButtonIndex)];
             self.status.text = [NSString stringWithFormat:@"You ordered a %@ ice cream.",flavour];
         }
     }];
}

-(IBAction)showSheet2:(UIButton*)sender
{
	NSArray* flavours = [NSArray arrayWithObjects:@"apple",@"pear",@"banana",nil];
    
	[[[OHActionSheet alloc] initWithTitle:@"What's your favorite fruit?"
                        cancelButtonTitle:@"Don't care"
                   destructiveButtonTitle:nil
                        otherButtonTitles:flavours
                               completion:^(OHActionSheet *sheet, NSInteger buttonIndex)
      {
          NSLog(@"button tapped: %ld",(long)buttonIndex);
          if (buttonIndex == sheet.cancelButtonIndex) {
              self.status.text = @"You didn't answer the question";
          }
          else if (buttonIndex == -1)
          {
              self.status.text = @"The action sheet timed out";
          }
          else
          {
              NSString* fruit = [flavours objectAtIndex:(buttonIndex-sheet.firstOtherButtonIndex)];
              self.status.text = [NSString stringWithFormat:@"Your favorite fruit is %@.",fruit];
          }
      }] showFromView:sender withTimeout:8 timeoutButtonIndex:-1];
}

- (IBAction)showSheet3:(UIBarButtonItem *)sender
{
    [OHActionSheet showFromView:(id)sender
                          title:@"Sheet from Bar"
              cancelButtonTitle:@"Cancel"
         destructiveButtonTitle:@"Delete"
              otherButtonTitles:@[@"Save"]
                     completion:^(OHActionSheet *sheet, NSInteger buttonIndex)
     {
         NSLog(@"Button tapped: %ld", (long)buttonIndex);
         if (buttonIndex == sheet.cancelButtonIndex)
         {
             self.status.text = @"You cancelled";
         }
         else if (buttonIndex == sheet.destructiveButtonIndex)
         {
             self.status.text = @"You chose to delete";
         }
         else
         {
             self.status.text = @"You chose to save";
         }
         
     }];
}

@end
