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
        double yComponent = UIScreen.mainScreen.bounds.size.height - 400;
        
        [self.view setFrame:CGRectMake(0, yComponent, frame.size.width, frame.size.height)];
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    
    panRecognizer.delegate = self;
    
    [self.view addGestureRecognizer:panRecognizer];
    if(self.destinationName && self.destinationState && self.destinationCity) {
        [self.location setText:[NSString stringWithFormat:@"%@", self.destinationName]];
        
        [self.address setText:[NSString stringWithFormat:@"%@, %@", self.destinationCity, self.destinationState]];
    }
    
    [self.routesTable registerNib:[UINib nibWithNibName:@"DefaultTableViewCell" bundle:nil] forCellReuseIdentifier:@"default"];
}

-(void) panGesture:(UIPanGestureRecognizer *) recognizer{
    CGPoint translation = [recognizer translationInView:self.view];
    
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    double y = CGRectGetMinX(self.view.frame);
    
    if ((y + translation.y >= 100) && (y + translation.y <= UIScreen.mainScreen.bounds.size.height - 150)) {
        CGRect rect = CGRectMake(0, y + translation.y, self.view.frame.size.width, self.view.frame.size.height);
        self.view.frame = rect;
        
        [recognizer setTranslation:CGPointZero inView:self.view];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        double duration = 0;
        if(velocity.y < 0){
            duration =  (y - 100) / -velocity.y;
        }
        else{
            duration = (UIScreen.mainScreen.bounds.size.height - 150 - y) / velocity.y;
        }
        
        duration = duration > 1.3 ? 1 : duration;
        
        [UIView animateWithDuration:0.3 animations:^{
            if  (velocity.y >= 0) {
                
                self.view.frame = CGRectMake(0,UIScreen.mainScreen.bounds.size.height - 150, self.view.frame.size.width, self.view.frame.size.height);
            } else {
                self.view.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height);
            }
            if ( velocity.y < 0 ) {
                [self.routesTable setScrollEnabled:true];
            }
        }];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.routesAvailable.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
    
    cell.textLabel.text = self.routesAvailable[indexPath.row].name;
    [cell.textLabel setFont:[UIFont fontWithName:@"Verdana" size:20]];
    [cell.textLabel setAdjustsFontSizeToFitWidth:true];
    return cell;
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)gestureRecognizer;
    
    double direction = [gesture velocityInView:self.view].y;
    
    double y = CGRectGetMinX(self.view.frame);
    
    if ((y == 100 && self.routesTable.contentOffset.y == 0 && direction > 0) || (y == UIScreen.mainScreen.bounds.size.height - 150)) {
        [self.routesTable setScrollEnabled:false];
    } else {
        [self.routesTable setScrollEnabled:true];
    }
    return false;
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
//        NSLog(@"%@",[NSString stringWithFormat:@"%f", routes[i].distance]);
        NSLog(@"%@",[NSString stringWithFormat:@"%@", routes[i].name]);
//        NSLog(@"%@",[NSString stringWithFormat:@"%f", routes[i].expectedTravelTime]);
        
//        NSLog(@"%@",[NSString stringWithFormat:@"%lu", (unsigned long)routes[i].transportType]);
    }
}


-(void) listRoute{
    NSLog(@"Routes implemented here...");
}
@end
