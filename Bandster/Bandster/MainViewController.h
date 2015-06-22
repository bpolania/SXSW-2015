//
//  MainViewController.h
//  Bandster
//
//  Created by Boris  on 3/19/15.
//  Copyright (c) 2015 LLT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MicrosoftBandKit_iOS/MicrosoftBandKit_iOS.h>

@interface MainViewController : UIViewController <MSBClientManagerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *loadingLabel;

@end
