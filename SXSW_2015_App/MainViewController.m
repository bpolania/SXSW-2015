//
//  MainViewController.m
//  SXSW_2015_App
//
//  Created by Boris  on 3/18/15.
//  Copyright (c) 2015 LLT. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize theTableView, scannedArtist, theImageView, bandNameLabel;

- (NSString *)normalizedArtistString {
    
    NSString *normalizedString = [scannedArtist stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    return [normalizedString lowercaseString];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    gtracksArray = [[NSMutableArray alloc] init];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"scanned value:%@",[self normalizedArtistString]);
    
    [self connectWarnerAPIforArtist:[self normalizedArtistString]];
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

- (NSMutableArray *)cleanSongsArray {
    
    NSMutableArray *bufferArray = [[NSMutableArray alloc] init];
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *trackDictionary in gtracksArray) {
        if (![bufferArray containsObject:[trackDictionary objectForKey:@"trackName"]]) {
            [bufferArray addObject:[trackDictionary objectForKey:@"trackName"]];
            [resultArray addObject:trackDictionary];
        }
        
    }
    
    return resultArray;
}

#pragma mark - NSURL Methods

- (NSString *)fixString:(NSString *)string {
    
    string = [string stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    string = [string stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    
    return string;
}


-(void)connectWarnerAPIforMediaURLwithToken:(NSString *)token forTrack:(NSString *)track {
    
    thequeryType = FIND_MEDIA_URL;
    
    NSString *cleanTrackString = [self fixString:track];
    NSString *cleanTokenString = [self fixString:token];
    NSString *userId = @"19b94847:radiolobe";
    
    NSString *placeString  = [NSString stringWithFormat:@"https://api.wmg.com:443/api/contentUrl/audio/trusted/urls/%@.json?country=US&profileName=64-heaac1-3gpp-90sec&userId=%@&right=clip_play&token=%@&_authorization=19b94847:871c39f2d32a50351025b4801887de31",cleanTrackString,userId,cleanTokenString];
    
    NSLog(@"URLRequestID:%@",placeString);
    
    [self URLConnect:placeString withMethod:@"GET"];
    
}

-(void)connectWarnerAPIforTrackInfo:(NSString *)track {
    
    thequeryType = FIND_SONG;
    
    NSString *cleanString = [self fixString:track];
    
    NSString *placeString  = [NSString stringWithFormat:@"https://api.wmg.com:443/api/catalog/tracks/%@.json?_authorization=19b94847:871c39f2d32a50351025b4801887de31",cleanString];
    
    //NSLog(@"TrackID:%@",placeString);
    
    [self URLConnect:placeString withMethod:@"GET"];
    
}

-(void)connectWarnerAPIforLicenseWithTrack:(NSString *)track {
    
    thequeryType = FIND_LICENSE;
    
    NSString *cleanString = [self fixString:track];
    
    NSString *placeString  = [NSString stringWithFormat:@"https://api.wmg.com:443/api/license/licensees/warner-primary/licenses/tracks/US/%@.json?_authorization=19b94847:871c39f2d32a50351025b4801887de31",cleanString];
    
    //NSLog(@"LicenseID:%@",placeString);
    
    [self URLConnect:placeString withMethod:@"GET"];
    
}

-(void)connectWarnerAPIforSongsWithArtist:(NSString *)artist {
    
    thequeryType = FIND_SONGS;
    
    NSString *cleanString = [self fixString:artist];
    
    NSString *placeString  = [NSString stringWithFormat:@"https://api.wmg.com:443/api/catalog/artists/%@/trackIds/discography.json?_authorization=19b94847:871c39f2d32a50351025b4801887de31",cleanString];
    
    [self URLConnect:placeString withMethod:@"GET"];
 
}

-(void)connectWarnerAPIforArtist:(NSString *)artist {
    
    thequeryType = FIND_ARTIST;
    
    NSString *placeString  = [NSString stringWithFormat:@"https://api.wmg.com:443/api/find/catalogues/warner/query.json?country=US&query=%@&prefix=last&typos=true&searchAttributes=combinedName&index=artist&distinct=false&limit=10&rights=clip_play&_authorization=19b94847:871c39f2d32a50351025b4801887de31",artist];
    
    //NSLog(@"QUESRY:%@",placeString);
    
    [self URLConnect:placeString withMethod:@"GET"];
    
    
    
}

-(void)URLConnect:(NSString *)urlString withMethod:(NSString *)method {
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:method];
    
    NSURLConnection *Connection =[[NSURLConnection alloc]
                                  initWithRequest:request
                                  delegate:self];
    
    if (Connection) {
        receivedData = [NSMutableData data];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [gtracksArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[gtracksArray objectAtIndex:indexPath.row] objectForKey:@"trackName"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedTrack = (int)indexPath.row;
    [self connectWarnerAPIforLicenseWithTrack:[[gtracksArray objectAtIndex:indexPath.row] objectForKey:@"trackId"]];
    
}

#pragma mark - NSURL Delegate Methods

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Connection success.");
    
    theResponse = [[NSString alloc] initWithBytes:[receivedData bytes] length:[receivedData length] encoding: NSUTF8StringEncoding];
    
    //NSLog(@"theResponse%@",theResponse);
    
    NSData *data = [theResponse dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    switch (thequeryType) {
        case FIND_ARTIST:{
                NSArray *artistsArray = [[NSArray alloc] init];
                artistsArray = [json objectForKey:@"artistIds"];
                
                //NSLog(@"count:%lu",(unsigned long)[artistsArray count]);
                
                for (NSDictionary *artistDictionary in artistsArray) {
                    if ([[artistDictionary objectForKey:@"artistName"] isEqualToString:scannedArtist]) {
                        [self connectWarnerAPIforSongsWithArtist:[artistDictionary objectForKey:@"artistId"]];
                        NSLog(@"trackName:%@",[artistDictionary objectForKey:@"artistName"]);
                        bandNameLabel.text = [artistDictionary objectForKey:@"artistName"];
                        dispatch_async(dispatch_get_global_queue(0,0), ^{
                            NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[artistDictionary objectForKey:@"imageUrl"]]];
                            if ( data == nil )
                                return;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                theImageView.image = [UIImage imageWithData: data];
                            });
                        });
                    }
                }
            
        }
            break;
        case FIND_SONGS: {
            NSArray *tracksArray = [[NSArray alloc] init];
            tracksArray = [json objectForKey:@"trackIds"];
            
            tracksArraySize = (int)[tracksArray count];
            
            for (NSDictionary *trackDictionary in tracksArray) {
                //[self connectWarnerAPIforLicenseWithTrack:[trackDictionary objectForKey:@"trackId"]];
                [self connectWarnerAPIforTrackInfo:[trackDictionary objectForKey:@"trackId"]];
            }
            NSLog(@"count that matters:%lu",(unsigned long)[tracksArray count]);
            
        }
            break;
        case FIND_LICENSE: {
            NSArray *licensesArray = [[NSArray alloc] init];
            licensesArray = [json objectForKey:@"trackRights"];
            
            NSString *token = [[licensesArray objectAtIndex:0] objectForKey:@"token"];
            NSString *trackId = [[gtracksArray objectAtIndex:selectedTrack] objectForKey:@"trackId"];
            NSLog(@"token:%@",token);
            NSLog(@"trackId:%@",trackId);
            
            [self connectWarnerAPIforMediaURLwithToken:token forTrack:trackId];
            
        }
            break;
        case FIND_SONG: {
            [gtracksArray addObject:json];
            
            if ([gtracksArray count] == tracksArraySize) {
                gtracksArray = [self cleanSongsArray];
                [theTableView reloadData];
            }
            
        }
            break;
        case FIND_MEDIA_URL: {
            //NSLog(@"theResponse%@",theResponse);
            NSString *urlString = [json objectForKey:@"url"];
            NSLog(@"urlString:%@",urlString);
            NSURL *url = [NSURL URLWithString:urlString];
            
            self.playerItem = [AVPlayerItem playerItemWithURL:url];
            self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
            
            [self.player play];
        }
            break;
        case FIND_SONG_IMAGE: {
            NSLog(@"Image URL%@",[json objectForKey:@"imageUrl"]);
            
        }
            break;
        default:
            break;
    }
    
    
    
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failure.:%@",error);
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
    
    theResponse = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding: NSUTF8StringEncoding];
    
    /*
     If the request is being made from the requestRandomPassword method it will request a new random password
     and create a new PFObject with the password and singly user id then it will log the PFObject id in the
     users default with the singly user as a key, then it registers the user to ejabberd
     */
    
}


@end
