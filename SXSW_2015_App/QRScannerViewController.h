//
//  QRScannerViewController.h
//  SXSW_2015_App
//
//  Created by Boris  on 3/18/15.
//  Copyright (c) 2015 LLT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface QRScannerViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (assign, nonatomic) BOOL touchToFocusEnabled;

- (BOOL) isCameraAvailable;
- (void) startScanning;
- (void) stopScanning;
- (void) setTorch:(BOOL) aStatus;

@end
