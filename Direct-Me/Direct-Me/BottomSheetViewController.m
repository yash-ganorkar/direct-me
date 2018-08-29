//
//  BottomSheetViewController.m
//  Direct-Me
//
//  Created by Yash Ganorkar on 8/27/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

#import "BottomSheetViewController.h"
#import "ViewController.h"

@interface BottomSheetViewController ()

@end

@implementation BottomSheetViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     [self prepareBackgroundView];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        double yComponent = UIScreen.mainScreen.bounds.size.height - 200;
        
        [self.view setFrame:CGRectMake(0, yComponent, frame.size.width, frame.size.height)];
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    
    [self.view addGestureRecognizer:panRecognizer];
    if(self.destinationName && self.destinationState && self.destinationCity) {
        [self.location setText:[NSString stringWithFormat:@"%@", self.destinationName]];
        
        [self.address setText:[NSString stringWithFormat:@"%@, %@", self.destinationCity, self.destinationState]];
    }
}

-(void) panGesture:(UIPanGestureRecognizer *) recognizer{
    CGPoint translatedPoint = [recognizer translationInView:recognizer.view.superview];
    
    double y = CGRectGetMinY(self.view.frame);
    
    [self.view setFrame:CGRectMake(0, y+translatedPoint.y, self.view.frame.size.width, self.view.frame.size.height)];
    
    [recognizer setTranslation:CGPointZero inView:self.view];

}

-(void) prepareBackgroundView{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffect = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    UIVisualEffectView *bluredView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    [bluredView.contentView addSubview:visualEffect];
    
    [visualEffect setFrame:UIScreen.mainScreen.bounds];
    [bluredView setFrame:UIScreen.mainScreen.bounds];
    [self.view insertSubview:bluredView atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rightButton:(id)sender {
}

- (IBAction)close:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        double yComponent = UIScreen.mainScreen.bounds.size.height - (CGRectGetMaxY(self.left.frame) + UIApplication.sharedApplication.statusBarFrame.size.height);
        
        [self.view setFrame:CGRectMake(0, yComponent, frame.size.width, frame.size.height)];
    }];
}
- (void) listRoutes:(NSArray<MKRoute *>*) routes {
    
    
    for(int i = 0; i < routes.count; i++){
        NSLog(@"%@",[NSString stringWithFormat:@"%f", routes[i].distance]);
        NSLog(@"%@",[NSString stringWithFormat:@"%@", routes[i].name]);
        NSLog(@"%@",[NSString stringWithFormat:@"%f", routes[i].expectedTravelTime]);

        NSLog(@"%@",[NSString stringWithFormat:@"%lu", (unsigned long)routes[i].transportType]);
    }
}

-(void) listRoute{
    NSLog(@"Routes implemented here...");
}
@end
