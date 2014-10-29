//
//  RMMoviePlayerController.h
//  Roam
//
//  Created by Vishal on 28/10/14.
//  Copyright (c) 2014 Vishal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface RMMoviePlayerController : UIViewController
{
    MPMoviePlayerController *mpplayer;
}
@property (nonatomic , weak ) IBOutlet UIImageView *imgView;

@end
