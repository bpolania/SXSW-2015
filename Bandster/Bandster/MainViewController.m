//
//  MainViewController.m
//  Bandster
//
//  Created by Boris  on 3/19/15.
//  Copyright (c) 2015 LLT. All rights reserved.
//

#import "MainViewController.h"
#import "ViewController.h"

@interface MainViewController ()

@property (nonatomic, weak) MSBClient *client;

@end

@implementation MainViewController

@synthesize loadingLabel;

- (void)viewWillAppear:(BOOL)animated {
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (IBAction)testTilePages:(id)sender {
    
    NSUUID *tileID = [[NSUUID alloc] initWithUUIDString:@"ABCDBA9F-12FD-47A5-83A9-E7270A43BB99"];
    [self.client.tileManager removeTileWithId:tileID completionHandler:nil];
    
    
}

- (IBAction)uploadData:(id)sender {
    
    NSMutableArray *playListArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *songDictionary = [[NSMutableDictionary alloc] init];
    
    [songDictionary setObject:@"Foxes - Youth [Seamus Haji Remix].mp3" forKey:@"songName"];
    [songDictionary setObject:@85 forKey:@"songTempo"];
    [playListArray addObject:songDictionary];
    
    songDictionary = [[NSMutableDictionary alloc] init];
    
    [songDictionary setObject:@"08 - Timber - Pitbull.mp3" forKey:@"songName"];
    [songDictionary setObject:@90 forKey:@"songTempo"];
    [playListArray addObject:songDictionary];
    
    PFObject *playList = [PFObject objectWithClassName:@"Playlists"];
    playList[@"playList"] = playListArray;
    [playList saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
        } else {
            // There was a problem, check error.description
        }
    }];
    
    
}

- (IBAction)startRoutine:(id)sender {
    
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"player"];
    
    vc.routine = [NSNumber numberWithInt:(int)[sender tag]];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Do any additional setup after loading the view, typically from a nib.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MSBand delegate

-(void)clientManager:(MSBClientManager *)cm clientDidConnect:(MSBClient *)client
{
    // handle connected event.
    NSLog(@"connected");
    [self.client.tileManager tilesWithCompletionHandler:^(NSArray *tiles,
                                                          NSError *error) {
        if (!error){
            // handle error
            BOOL isIntalled = NO;
            
            for (MSBTile *tile in tiles) {
                if ([tile.tileId.UUIDString isEqualToString:@"bandarama"]) {
                    isIntalled = YES;
                }
            }
            
            if (!isIntalled) {
                if (self.client && self.client.isDeviceConnected)
                {
                    
                    NSLog(@"Creating tile...");
                    
                    NSString *tileName = @"A tile";
                    
                    MSBIcon *tileIcon = [MSBIcon iconWithUIImage:[UIImage imageNamed:@"A.png"] error:nil];
                    MSBIcon *smallIcon = [MSBIcon iconWithUIImage:[UIImage imageNamed:@"Aa.png"] error:nil];
                    
                    NSUUID *tileID = [[NSUUID alloc] initWithUUIDString:@"ABCDBA9F-12FD-47A5-83A9-E7270A43BB99"];
                    MSBTile *tile = [MSBTile tileWithId:tileID name:tileName tileIcon:tileIcon smallIcon:smallIcon error:nil];
                    
                    MSBTextBlock *textBlock_1 = [[MSBTextBlock alloc] initWithRect:[MSBRect rectwithX:0 y:0 width:230 height:40] font:MSBTextBlockFontSmall baseline:25];
                    textBlock_1.elementId = 11;
                    textBlock_1.horizontalAlignment = MSBPageElementHorizontalAlignmentLeft;
                    textBlock_1.baselineAlignment = MSBTextBlockBaselineAlignmentAbsolute;
                    textBlock_1.color = [MSBColor colorWithRed:0xff green:0xff blue:0xff];
                    
                    MSBTextBlock *textBlock_2 = [[MSBTextBlock alloc] initWithRect:[MSBRect rectwithX:0 y:5 width:230 height:40] font:MSBTextBlockFontSmall baseline:25];
                    textBlock_2.elementId = 10;
                    textBlock_2.color = [MSBColor colorWithRed:0xff green:0xff blue:0xff];
                    
                    
                    MSBFlowList *flowList = [[MSBFlowList alloc] initWithRect:[MSBRect rectwithX:15 y:0 width:260 height:105] orientation:MSBFlowListOrientationVertical];
                    flowList.margins = [MSBMargins marginsWithLeft:0 top:0 right:0 bottom:0];
                    flowList.color = nil;
                    [flowList.children addObject:textBlock_1];
                    [flowList.children addObject:textBlock_2];
                    
                    MSBPageLayout *page = [MSBPageLayout new];
                    page.root = flowList;
                    [tile.pageLayouts addObject:page];
                    
                    [self.client.tileManager addTile:tile completionHandler:^(NSError *error) {
                        if (!error || error.code == MSBErrorCodeTileAlreadyExist)
                        {
                            
                            NSLog(@"Creating page...");
                            
                            NSUUID *pageID = [[NSUUID alloc] initWithUUIDString:@"1234BA9F-12FD-47A5-83A9-E7270A43BB99"];
                            NSArray *pageValues = @[[MSBPageTextData pageTextDataWithElementId:11 text:@"Welcome to" error:nil],[MSBPageTextData pageTextDataWithElementId:10 text:@"Bandarama" error:nil]];
                            MSBPageData *page = [MSBPageData pageDataWithId:pageID templateIndex:0 value:pageValues];
                            
                            [self.client.tileManager setPages:@[page] tileId:tile.tileId completionHandler:^(NSError *error) {
                                if (!error)
                                {
                                    NSLog(@"Successfully Finished!!!.");
                                    loadingLabel.hidden = YES;
                                }
                                else
                                {
                                    NSLog(@"%@",error.localizedDescription);
                                }
                            }];
                        }
                        else
                        {
                            NSLog(@"%@",error.localizedDescription);
                            
                        }
                    }];
                }
                else
                {
                    NSLog(@"Band is not connected. Please wait....");
                }
            }
        }
    }];
    
}
-(void)clientManager:(MSBClientManager *)cm clientDidDisconnect:(MSBClient *)client
{
    
}
-(void)clientManager:(MSBClientManager *)cm client:(MSBClient *)client didFailToConnectWithError:(NSError *)error
{
    // handle failure event.
    NSLog(@"Not connected");
}

@end
