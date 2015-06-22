//
//  ViewController.m
//  Bandster
//
//  Created by Boris  on 3/18/15.
//  Copyright (c) 2015 LLT. All rights reserved.
//

#import "ViewController.h"
#import "VisualizerView.h"

@interface ViewController ()

@property (nonatomic, weak) MSBClient *client;

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) NSArray *playItems;
@property (strong, nonatomic) NSArray *pauseItems;
@property (strong, nonatomic) UIBarButtonItem *playBBI;
@property (strong, nonatomic) UIBarButtonItem *pauseBBI;

// Add properties here
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) VisualizerView *visualizer;

@end

@implementation ViewController {
    BOOL _isBarHide;
    BOOL _isPlaying;
}

@synthesize routine;

- (void)startHeartRateReading {
    
    NSError *subscriptionError;
    [self.client.sensorManager startHearRateUpdatesToQueue:nil errorRef:&subscriptionError withHandler:^(MSBSensorHeartRateData *heartRateData, NSError *error) {
        
        if (!error){
            // handle error
            NSLog(@"Heart Rate:%lu",(unsigned long)heartRateData.heartRate);
            NSLog(@"Current BPM:%lu",(unsigned long)currentBPM);
            
            if (heartRateData.heartRate < currentBPM) {
                NSLog(@"red");
                
                if (inTheZone) {
                    [self.client.notificationManager
                     vibrateWithType:MSBVibrationTypeNotificationAlarm
                     completionHandler:^(NSError *error)
                     {
                         if (error){
                             // handle error
                         }
                     }];
                    //Change Text Zone
                    NSUUID *pageID = [[NSUUID alloc] initWithUUIDString:@"1234BA9F-12FD-47A5-83A9-E7270A43BB99"];
                    NSArray *pageValues = [[NSArray alloc] init];
                    pageValues = @[[MSBPageTextData pageTextDataWithElementId:11 text:[NSString stringWithFormat:@"Now Playing: %@",[[playList objectAtIndex:currentSong] objectForKey:@"songName"]] error:nil],[MSBPageTextData pageTextDataWithElementId:10 text:@"Not in the zone!" error:nil]];
                    MSBPageData *page = [MSBPageData pageDataWithId:pageID templateIndex:0 value:pageValues];
                    NSUUID *tileID = [[NSUUID alloc] initWithUUIDString:@"ABCDBA9F-12FD-47A5-83A9-E7270A43BB99"];
                    [self.client.tileManager setPages:@[page] tileId:tileID completionHandler:^(NSError *error) {
                        if (!error)
                        {
                            NSLog(@"Successfully Finished!!!.");
                        }
                        else
                        {
                            NSLog(@"%@",error.localizedDescription);
                        }
                    }];
                    inTheZone = NO;
                }
                
                
                [_visualizer setRed];
                _audioPlayer.rate = 0.5;
                
            } else {
                NSLog(@"green");
                
                if (!inTheZone) {
                    
                    // Do any additional setup after loading the view, typically from a nib.
                    
                    // Construct URL to sound file
                    NSString *path = [NSString stringWithFormat:@"%@/aplausos.mp3", [[NSBundle mainBundle] resourcePath]];
                    NSURL *soundUrl = [NSURL fileURLWithPath:path];
                    
                    // Create audio player object and initialize with URL to sound
                    _transitionsPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
                    _transitionsPlayer.enableRate = YES;
                    
                    [_transitionsPlayer play];
                     
                    
                    [self.client.notificationManager
                     vibrateWithType:MSBVibrationTypeNotificationAlarm
                     completionHandler:^(NSError *error)
                     {
                         if (error){
                             // handle error
                         }
                     }];
                    //Change Text Zone
                    NSUUID *pageID = [[NSUUID alloc] initWithUUIDString:@"1234BA9F-12FD-47A5-83A9-E7270A43BB99"];
                    NSArray *pageValues = [[NSArray alloc] init];
                    pageValues = @[[MSBPageTextData pageTextDataWithElementId:11 text:[NSString stringWithFormat:@"Now Playing: %@",[[playList objectAtIndex:currentSong] objectForKey:@"songName"]] error:nil],[MSBPageTextData pageTextDataWithElementId:10 text:@"You're in the zone!" error:nil]];
                    MSBPageData *page = [MSBPageData pageDataWithId:pageID templateIndex:0 value:pageValues];
                    NSUUID *tileID = [[NSUUID alloc] initWithUUIDString:@"ABCDBA9F-12FD-47A5-83A9-E7270A43BB99"];
                    [self.client.tileManager setPages:@[page] tileId:tileID completionHandler:^(NSError *error) {
                        if (!error)
                        {
                            NSLog(@"Successfully Finished!!!.");
                        }
                        else
                        {
                            NSLog(@"%@",error.localizedDescription);
                        }
                    }];
                    inTheZone = YES;
                }
                
                [_visualizer setGreen];
                _audioPlayer.rate = 1.0;
                
            }
            
        } else {
            NSLog(@"Error:%@",error);
        }
    
    
    }];
    
    if (subscriptionError){
        // failed to subscribe.
    }
}

- (IBAction)changeTrackRate:(id)sender {
    
    UISlider *slider = (UISlider *)sender;
    NSLog(@"SliderValue ... %f",[slider value]/10.0);
    _audioPlayer.rate = [slider value]/10;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    // Do any additional setup after loading the view, typically from a nib.
    /*
    // Construct URL to sound file
    NSString *path = [NSString stringWithFormat:@"%@/08 - Timber - Pitbull.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    
    // Create audio player object and initialize with URL to sound
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    _audioPlayer.enableRate = YES;
    
    [_audioPlayer play];
    
    */
    
    currentSong = 0;
    
    [self configureBars];
    
    [self configureAudioSession];
    
    self.visualizer = [[VisualizerView alloc] initWithFrame:self.view.frame];
    [_visualizer setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_backgroundView addSubview:_visualizer];
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
    
    if (!self.client.isDeviceConnected)
    {
        [MSBClientManager sharedManager].delegate = self;
        NSArray	*clients = [[MSBClientManager sharedManager] attachedClients];
        _client = [clients firstObject];
        if ( _client == nil )
        {
            //[self output:@"Failed! No Bands attached."];
            NSLog(@"Failed! No Bands attached.");
            return;
        }
        
        [[MSBClientManager sharedManager] connectClient:_client];
        //[self output:@"Please wait. Connecting to Band..."];
        NSLog(@"Please wait. Connecting to Band...");
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Playlists"];
    [query whereKey:@"listId" equalTo:routine];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
                playList = object[@"playList"];
                [self configureAudioPlayerWithSong:[[playList objectAtIndex:0] objectForKey:@"songName"]];
                currentBPM = [[[playList objectAtIndex:0] objectForKey:@"songTempo"] intValue];
                
                UINavigationItem *navTitleItem = [[UINavigationItem alloc] initWithTitle:[NSString stringWithFormat:@"Now Playing: %@",[[playList objectAtIndex:0] objectForKey:@"songName"]]];
                [_navBar pushNavigationItem:navTitleItem animated:NO];
                
                //Change Text Zone
                NSUUID *pageID = [[NSUUID alloc] initWithUUIDString:@"1234BA9F-12FD-47A5-83A9-E7270A43BB99"];
                NSArray *pageValues = @[[MSBPageTextData pageTextDataWithElementId:11 text:[NSString stringWithFormat:@"Now Playing: %@",[[playList objectAtIndex:0] objectForKey:@"songName"]] error:nil],[MSBPageTextData pageTextDataWithElementId:10 text:@"Not in the zone!" error:nil]];
                MSBPageData *page = [MSBPageData pageDataWithId:pageID templateIndex:0 value:pageValues];
                NSUUID *tileID = [[NSUUID alloc] initWithUUIDString:@"ABCDBA9F-12FD-47A5-83A9-E7270A43BB99"];
                [self.client.tileManager setPages:@[page] tileId:tileID completionHandler:^(NSError *error) {
                    if (!error)
                    {
                        NSLog(@"Successfully Finished!!!.");
                    }
                    else
                    {
                        NSLog(@"%@",error.localizedDescription);
                    }
                }];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    [self configureAudioPlayerWithSong:[[playList objectAtIndex:0] objectForKey:@"songName"]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self toggleBars];
}

- (void)configureBars {
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    CGRect frame = self.view.frame;
    
    self.backgroundView = [[UIView alloc] initWithFrame:frame];
    [_backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_backgroundView setBackgroundColor:[UIColor blackColor]];
    
    [self.view addSubview:_backgroundView];
    
    // NavBar
    self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, -44, frame.size.width, 44)];
    self.navBar.delegate = self;
    [_navBar setBarStyle:UIBarStyleBlackTranslucent];
    [_navBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    UINavigationItem *navTitleItem = [[UINavigationItem alloc] initWithTitle:@""];
    [_navBar pushNavigationItem:navTitleItem animated:NO];
    
    [self.view addSubview:_navBar];
    
    // ToolBar
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 420, frame.size.width, 44)];
    [_toolBar setBarStyle:UIBarStyleBlackTranslucent];
    [_toolBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    //UIBarButtonItem *pickBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(pickSong)];
    
    self.playBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPause)];
    
    self.pauseBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(playPause)];
    
    UIBarButtonItem *leftFlexBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *rightFlexBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.playItems = [NSArray arrayWithObjects:leftFlexBBI, _playBBI, rightFlexBBI, nil];
    self.pauseItems = [NSArray arrayWithObjects:leftFlexBBI, _pauseBBI, rightFlexBBI, nil];
    
    [_toolBar setItems:_playItems];
    
    [self.view addSubview:_toolBar];
    
    _isBarHide = YES;
    _isPlaying = NO;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [_backgroundView addGestureRecognizer:tapGR];
}

- (void)toggleBars {
    CGFloat navBarDis = -44;
    CGFloat toolBarDis = 44;
    if (_isBarHide ) {
        navBarDis = -navBarDis;
        toolBarDis = -toolBarDis;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint navBarCenter = _navBar.center;
        navBarCenter.y += navBarDis;
        [_navBar setCenter:navBarCenter];
        
        CGPoint toolBarCenter = _toolBar.center;
        toolBarCenter.y += toolBarDis;
        [_toolBar setCenter:toolBarCenter];
    }];
    
    _isBarHide = !_isBarHide;
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGR {
    [self toggleBars];
}

- (void)configureAudioPlayerWithSong:(NSString *)songName {
    NSURL *audioFileURL = [[NSBundle mainBundle] URLForResource:songName withExtension:@"mp3"];
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:&error];
    self.audioPlayer.enableRate = YES;
    self.audioPlayer.delegate = self;
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [_audioPlayer setNumberOfLoops:0];
    [_audioPlayer setMeteringEnabled:YES];
    [_visualizer setAudioPlayer:_audioPlayer];
}

- (void)configureAudioSession {
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
    }
}

#pragma mark - Music control

- (void)playPause {

    [_visualizer setRed];
    if (_isPlaying) {
        // Pause audio here
        [_audioPlayer pause];
        
        [_toolBar setItems:_playItems];  // toggle play/pause button
    }
    else {
        // Play audio here
        
        [_audioPlayer play];
        
        [_toolBar setItems:_pauseItems]; // toggle play/pause button
    }
    _isPlaying = !_isPlaying;
    
    if (self.client.isDeviceConnected)
    {
        [self startHeartRateReading];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MSBand delegate

-(void)clientManager:(MSBClientManager *)cm clientDidConnect:(MSBClient *)client
{
    // handle connected event.
    NSLog(@"connected");
    [self startHeartRateReading];
}
-(void)clientManager:(MSBClientManager *)cm clientDidDisconnect:(MSBClient *)client
{
    
}
-(void)clientManager:(MSBClientManager *)cm client:(MSBClient *)client didFailToConnectWithError:(NSError *)error
{
    // handle failure event.
    NSLog(@"Not connected");
}

#pragma mark - AudioPlayer Delegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    NSLog(@"loco");
    
    if (currentSong < [playList count]) {
        currentSong++;
    } else {
        currentSong = 0;
    }
    
    NSUUID *pageID = [[NSUUID alloc] initWithUUIDString:@"1234BA9F-12FD-47A5-83A9-E7270A43BB99"];
    NSArray *pageValues = @[[MSBPageTextData pageTextDataWithElementId:11 text:[NSString stringWithFormat:@"Now Playing: %@",[[playList objectAtIndex:currentSong] objectForKey:@"songName"]] error:nil]];
    MSBPageData *page = [MSBPageData pageDataWithId:pageID templateIndex:0 value:pageValues];
    NSUUID *tileID = [[NSUUID alloc] initWithUUIDString:@"ABCDBA9F-12FD-47A5-83A9-E7270A43BB99"];
    [self.client.tileManager setPages:@[page] tileId:tileID completionHandler:^(NSError *error) {
        if (!error)
        {
            NSLog(@"Successfully Finished!!!.");
        }
        else
        {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    
    [self configureAudioPlayerWithSong:[[playList objectAtIndex:currentSong] objectForKey:@"songName"]];
    [_audioPlayer play];
    
}

#pragma mark - UINavigationBar Delegate

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
    NSLog(@"BACK");
    
    [_audioPlayer stop];
    [self.navigationController popViewControllerAnimated:YES];
    
    
    return YES;
}

@end
