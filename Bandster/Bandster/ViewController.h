//
//  ViewController.h
//  Bandster
//
//  Created by Boris  on 3/18/15.
//  Copyright (c) 2015 LLT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MicrosoftBandKit_iOS/MicrosoftBandKit_iOS.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>

@interface ViewController : UIViewController <MSBClientManagerDelegate, AVAudioPlayerDelegate, UINavigationBarDelegate> {
    
    AVAudioPlayer *_audioPlayer;
    NSArray *playList;
    
    int currentBPM;
    int currentSong;
    
    BOOL inTheZone;
    
    
    AVAudioPlayer *_transitionsPlayer;
}

@property (nonatomic, strong) NSNumber *routine;

@end

