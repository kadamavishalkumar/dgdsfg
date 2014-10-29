//
//  RMMoviePlayerController.m
//  Roam
//
//  Created by Vishal on 28/10/14.
//  Copyright (c) 2014 Vishal. All rights reserved.
//

#import "RMMoviePlayerController.h"

@interface RMMoviePlayerController ()

@end

@implementation RMMoviePlayerController


-(NSURL *)localMovieURL
{
	NSURL *theMovieURL = nil;
	NSBundle *bundle = [NSBundle mainBundle];
	if (bundle)
	{
		NSString *moviePath = [bundle pathForResource:@"Movie" ofType:@"m4v"];
		if (moviePath)
		{
			theMovieURL = [NSURL fileURLWithPath:moviePath];
		}
	}
    return theMovieURL;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self playMovie];

}

//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:YES];
//    [self playMovie];
//}
//
//- (void)viewDidDisappear:(BOOL)animated{
//    [super viewDidDisappear:YES];
//    [mpplayer.view removeFromSuperview];
//    [self removeMovieNotificationHandlers:mpplayer];
//    mpplayer = nil;
//
//}

- (void)playMovie{
    
    mpplayer  = [[MPMoviePlayerController alloc] init];
    mpplayer.contentURL  = [self localMovieURL];
    NSMutableArray *timerarry = [[NSMutableArray alloc]init];
    [timerarry addObject:[NSNumber numberWithInt:1.f]];

    [mpplayer requestThumbnailImagesAtTimes:timerarry timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mpMoviePlayerThumbnailImageRequestDidFinishNotification:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:mpplayer];
    mpplayer.view.frame = CGRectMake(0, 0, _imgView.frame.size.width, _imgView.frame.size.height);
    mpplayer.shouldAutoplay = NO;
    mpplayer.initialPlaybackTime = 0.7;
    mpplayer.controlStyle = MPMovieControlStyleEmbedded;
    mpplayer.scalingMode = MPMovieScalingModeAspectFill;
    [self installMovieNotificationObservers:mpplayer];
    [_imgView addSubview:mpplayer.view];
    


}
-(void)mpMoviePlayerThumbnailImageRequestDidFinishNotification: (NSDictionary*)info{
    
    //UIImage *image = [info objectForKey:MPMoviePlayerThumbnailImageKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark Install Movie Notifications
-(void)installMovieNotificationObservers:(MPMoviePlayerController*)player
{
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:player];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:player];
}

#pragma mark Remove Movie Notification Handlers

-(void)removeMovieNotificationHandlers:(MPMoviePlayerController*)player
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    //[[NSNotificationCenter defaultCenter]removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:player];
}

/* Delete the movie player object, and remove the movie notification observers. */

-(void)deletePlayerAndNotificationObservers
{
    //[self removeMovieNotificationHandlers];
    
}
#pragma mark Movie Notification Handlers
#pragma mark -----------------------
#pragma mark MPMoviePlayer Notification Methods

-(void)moviePlaybackStateDidChange:(NSNotification *)notification
{
    MPMoviePlayerViewController *moviePlayerViewController = [notification object];
    
    if (moviePlayerViewController.moviePlayer.loadState == MPMovieLoadStatePlayable &&
        moviePlayerViewController.moviePlayer.playbackState != MPMoviePlaybackStatePlaying)
    {
        [moviePlayerViewController.moviePlayer play];
    }
    // Register to receive a notification when the movie has finished playing.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:moviePlayerViewController];
    moviePlayerViewController = nil;
}
/*  Notification called when the movie finished playing. */
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    MPMoviePlayerController *player2 = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player2];
//    if ([player2
//         respondsToSelector:@selector(setFullscreen:animated:)])
//    {
//        [player2.view removeFromSuperview];
//    }
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
	switch ([reason integerValue])
	{
            /* The end of the movie was reached. */
		case MPMovieFinishReasonPlaybackEnded:
            /*
             Add your code here to handle MPMovieFinishReasonPlaybackEnded.
             */
			break;
            
            /* An error was encountered during playback. */
		case MPMovieFinishReasonPlaybackError:
            //NSLog(@"An error was encountered during playback");
            
			break;
            
            /* The user stopped playback. */
		case MPMovieFinishReasonUserExited:
            
			break;
            
		default:
			break;
	}
}


/* Handle movie load state changes. */
- (void)loadStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *player21 = notification.object;
	MPMovieLoadState loadState = player21.loadState;
    
	/* The load state is not known at this time. */
	if (loadState & MPMovieLoadStateUnknown)
	{
        
        //NSLog(@" unknow");
	}
	
	/* The buffer has enough data that playback can begin, but it
	 may run out of data before playback finishes. */
	if (loadState & MPMovieLoadStatePlayable)
	{
        //NSLog(@" playable");
        
	}
	
	/* Enough data has been buffered for playback to continue uninterrupted. */
	if (loadState & MPMovieLoadStatePlaythroughOK)
	{
        // Add an overlay view on top of the movie view
        //NSLog(@" playthrough");
        
	}
	
	/* The buffering of data has stalled. */
	if (loadState & MPMovieLoadStateStalled)
	{
        //NSLog(@" stalled");
	}
}

/* Called when the movie playback state has changed. */
- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
	MPMoviePlayerController *ppPlayer = notification.object;
    
	/* Playback is currently stopped. */
	if (ppPlayer.playbackState == MPMoviePlaybackStateStopped )
	{
        [ppPlayer endSeeking];
        [ppPlayer.view removeFromSuperview];
        ppPlayer = nil;
        mpplayer = nil;
        [self playMovie];
	}
	/*  Playback is currently under way. */
	else if (ppPlayer.playbackState == MPMoviePlaybackStatePlaying)
	{
        //NSLog(@" playing");
	}
	/* Playback is currently paused. */
	else if (ppPlayer.playbackState == MPMoviePlaybackStatePaused)
	{
        //NSLog(@" paused");
        
        
	}
	/* Playback is temporarily interrupted, perhaps because the buffer
	 ran out of content. */
	else if (ppPlayer.playbackState == MPMoviePlaybackStateInterrupted)
	{
        //NSLog(@" interrupted");
	}
}


@end
