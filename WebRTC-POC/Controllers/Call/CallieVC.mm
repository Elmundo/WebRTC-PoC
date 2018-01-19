//
//  CallieVC.m
//  WebRTC-POC
//
//  Created by BARIS YILMAZ on 17/11/2017.
//  Copyright © 2017 BARIS YILMAZ. All rights reserved.
//

#import "CallieVC.h"

@interface CallieVC ()

@end

@implementation CallieVC

#pragma mark - Build-in Methods
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWidgets];
//    [self addObservers];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addObservers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallActive_Action:) name:@"CallActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallStatus_Action:) name:@"CallStatus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallEnd_Action:) name:@"CallEnd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallReject_Action:) name:@"CellRejected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallHold_Action:) name:@"CallHold" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallUnhold_Action:) name:@"CallUnhold" object:nil];
}

-(void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initWidgets {
    self.callingPersonIV.layer.cornerRadius = self.callingPersonIV.frame.size.width/2;
    self.callingPersonIV.layer.masksToBounds = true;
    [self.callingPersonIV setBackgroundColor:[UIColor grayColor]];
    
    // Blur Effect
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurView setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.view insertSubview:blurView atIndex:0];
    
    [self setConstraintsWithBlurEffectView:blurView];
}

- (void)setConstraintsWithBlurEffectView:(UIVisualEffectView *)blurView{
    NSMutableArray<NSLayoutConstraint*> *constraints = [[NSMutableArray<NSLayoutConstraint *> alloc] initWithCapacity:6];
    NSLayoutConstraint *constraint;
    constraint = [NSLayoutConstraint constraintWithItem:self.view
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:blurView
                                              attribute:NSLayoutAttributeWidth
                                             multiplier:1.0f constant:0];
    [constraints addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.view
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:blurView attribute:NSLayoutAttributeHeight
                                             multiplier:1.0f constant:0];
    [constraints addObject:constraint];
    
    [self.view addConstraints:constraints];
}

#pragma mark - Actions
- (IBAction)decline_Action:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate callieCallDeclined];
    }
    
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)accept_Action:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate callieCallAccepted];
    }
}

-(void)onCallActive_Action:(NSDictionary *)userInfo {
   NSString *callId = [userInfo objectForKey:@"data"];
}

-(void)onCallStatus_Action:(NSDictionary *)userInfo {
    NSString *callId = [userInfo objectForKey:@"data"];
}

-(void)onCallEnd_Action:(NSDictionary *)userInfo {
    NSString *callId = [userInfo objectForKey:@"data"];
}

-(void)onCallReject_Action:(NSDictionary *)userInfo {
    NSString *callId = [userInfo objectForKey:@"data"];
}

-(void)onCallHold_Action:(NSDictionary *)userInfo {
    NSString *callId = [userInfo objectForKey:@"data"];
}

-(void)onCallUnhold_Action:(NSDictionary *)userInfo {
    NSString *callId = [userInfo objectForKey:@"data"];
}

@end
