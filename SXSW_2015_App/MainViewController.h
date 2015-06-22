//
//  MainViewController.h
//  SXSW_2015_App
//
//  Created by Boris  on 3/18/15.
//  Copyright (c) 2015 LLT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum queryTypes
{
    FIND_ARTIST,
    FIND_SONGS,
    FIND_SONG,
    FIND_SONG_IMAGE,
    FIND_LICENSE,
    FIND_MEDIA_URL
    
} QueryType;

@interface MainViewController : UIViewController <NSURLConnectionDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    // HTTP Request Related Local Variables
    NSMutableData *receivedData;
    NSURLConnection *urlConnection;
    NSString *theResponse;
    
    QueryType thequeryType;
    
    //TableView Variables
    NSMutableArray *gtracksArray;
    int tracksArraySize;
    int selectedTrack;
    
}

@property (nonatomic, strong) NSString *scannedArtist;

@property (nonatomic, strong) IBOutlet UITableView *theTableView;
@property (nonatomic, strong) IBOutlet UIImageView *theImageView;
@property (nonatomic, strong) IBOutlet UILabel *bandNameLabel;

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;

@end
