//
//  ViewController.m
//  Pop Toss
//
//  Created by Dick Verbunt on 24-12-12.
//  Copyright (c) 2012 Bart van den Berg. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "BumpClient.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController()
{
    int ranNumb;
    UITextView *resultText;
}
@end

@implementation ViewController



- (void) configureBump {
    
    ranNumb = [self randomNumber];
    
    [BumpClient configureWithAPIKey:@"10d19ef8333b456484a634694c1d3bd2" andUserID:[[UIDevice currentDevice] name]];
    
    [[BumpClient sharedClient] setMatchBlock:^(BumpChannelID channel) {
        [self logToTextView:[NSString stringWithFormat:@"Matched with user: %@", [[BumpClient sharedClient] userIDForChannel:channel]]];
        
        [[BumpClient sharedClient] confirmMatch:YES onChannel:channel];
    }];
    
        
        [[BumpClient sharedClient] setChannelConfirmedBlock:^(BumpChannelID channel) {
            
        [self logToTextView:[NSString stringWithFormat:@"Channel with %@ confirmed.", [[BumpClient sharedClient] userIDForChannel:channel]]];
            
            
            [[BumpClient sharedClient] sendData:[[NSString stringWithFormat:@"%i",ranNumb] dataUsingEncoding:NSUTF8StringEncoding]
                                      toChannel:channel];
        }];
   
    
    
    [[BumpClient sharedClient] setDataReceivedBlock:^(BumpChannelID channel, NSData *data) {
        [self logToTextView:[NSString stringWithFormat:@"Data received from %@: %@",
                             [[BumpClient sharedClient] userIDForChannel:channel],
                             [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding]]];
        int value = [[NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding] intValue];
        if([self CheckDidIWin:value])
        {
            [self logToTextView:@"YESSSSSSS!!!"];
            [self playSound:@"yes"];

        }
        else
        {
            [self logToTextView:@"NOO!!!!!!!"];
            [self playSound:@"no"];
        }
        
        NSLog(@"Data received from %@: %@",
              [[BumpClient sharedClient] userIDForChannel:channel],
              [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding]);
    }];
    
    [[BumpClient sharedClient] setConnectionStateChangedBlock:^(BOOL connected) {
        if (connected) {
            [self logToTextView:@"Bump connected..."];
            NSLog(@"Bump connected...");
        } else {
            [self logToTextView:@"Bump disconnected..."];
            NSLog(@"Bump disconnected...");
        }
    }];
    
    [[BumpClient sharedClient] setBumpEventBlock:^(bump_event event) {
        switch(event) {
            case BUMP_EVENT_BUMP:
                NSLog(@"Bump detected.");
                break;
            case BUMP_EVENT_NO_MATCH:
                NSLog(@"No match.");
                break;
        }
    }];
}

-(void) playSound:(NSString *)WithTrack
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:WithTrack ofType:@"aiff"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
    //[soundPath release];
    NSLog(@"soundpath retain count: %d", [soundPath retainCount]);
}

- (void) releaseBump{
    [BumpClient release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureBump];
    [self addUserInterface];
}

-(void)addUserInterface
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(10, 10, 100, 40);
    [button setTitle:@"Toss!" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    resultText = [[UITextView alloc] initWithFrame:CGRectMake(10, 60, 300, 100)];
    [resultText setText:@"Please start..."];
    [self.view addSubview: resultText]; //because its ViewController
    
}

-(void)buttonPressed {
    
    ranNumb = [self randomNumber];
    NSLog(@"My number is %i",ranNumb);
    [self logToTextView:[NSString stringWithFormat:@"Gegooid: %i ",ranNumb]];
    
}

-(void)logToTextView:(NSString *)log
{
    NSString *result = [resultText text];
    [resultText setText:[NSString stringWithFormat:@"%@\n%@",log, result]];
}

-(bool)CheckDidIWin:(int)WithInput
{
    if(ranNumb <= WithInput)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(int) randomNumber
{
    u_int32_t randomNumbers = (arc4random() % ((unsigned)RAND_MAX + 1));
    return randomNumbers;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_btnToss release];
    [_txtOutput release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBtnToss:nil];
    [self setTxtOutput:nil];
    [super viewDidUnload];
}
@end
