//
//  TimelineViewController.m
//  ImitationWeChat
//
//  Created by wany on 15/7/26.
//  Copyright (c) 2015年 wany. All rights reserved.
//

#import "TimelineViewController.h"

static NSString *TIMELINECELLIDENTIFIER = @"timeLineCellIdentifier";
static CGFloat TABLEHEADERVIEHEIGHT = 300.0f;
static CGFloat REFLASHMAXCENTERY = 100.0f;
static CGFloat REFLSAHINITCENTERY = 40.0f;

static CGFloat USERFACESIZE = 60.0f;

@interface TimelineViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    //是否正在刷新
    BOOL isRefreshing;
    //是否可以开始刷新
    BOOL startRefreshing;
}
@property (nonatomic,strong) UITableView *timeLineTableView;
@property (nonatomic,strong) UIImageView *tableViewHeaderView;


@property (nonatomic,strong) UIImageView *albumReflashImageView;
@property (nonatomic,strong) UIImageView *userFaceImageView;
@end

@implementation TimelineViewController
-(UIImageView *)userFaceImageView{
    if (!_userFaceImageView) {
        _userFaceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-USERFACESIZE-10, TABLEHEADERVIEHEIGHT-USERFACESIZE,USERFACESIZE , USERFACESIZE)];
        _userFaceImageView.image = [UIImage imageNamed:@"111"];
        _userFaceImageView.userInteractionEnabled = YES;
        _userFaceImageView.layer.borderWidth = 1;
        _userFaceImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(faceImageViewClick)];
        [_userFaceImageView addGestureRecognizer:tap];
        
    }
    return _userFaceImageView;
}

-(UIImageView *)albumReflashImageView{
    if (!_albumReflashImageView) {
        UIImage *relahsImage = [UIImage imageNamed:@"AlbumReflashIcon"];
        _albumReflashImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, REFLSAHINITCENTERY, relahsImage.size.width, relahsImage.size.height)];
        _albumReflashImageView.centerY = REFLSAHINITCENTERY;
        _albumReflashImageView.image = relahsImage;
    }
    return _albumReflashImageView;
}

-(UIImageView *)tableViewHeaderView{
    if (!_tableViewHeaderView) {
        _tableViewHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TABLEHEADERVIEHEIGHT)];
        _tableViewHeaderView.contentMode = UIViewContentModeScaleAspectFill;
        _tableViewHeaderView.clipsToBounds = YES;
        _tableViewHeaderView.userInteractionEnabled = YES;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"coffe" ofType:@"jpg"];
        _tableViewHeaderView.image = [UIImage imageWithContentsOfFile:path];
    }
    return _tableViewHeaderView;
}
-(UITableView *)timeLineTableView{
    if (!_timeLineTableView) {
        _timeLineTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -STATUS_AND_NAV_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT+STATUS_AND_NAV_BAR_HEIGHT) style:UITableViewStylePlain];
        [self.view addSubview:_timeLineTableView];
        
        _timeLineTableView.delegate = self;
        _timeLineTableView.dataSource = self;
        _timeLineTableView.tableFooterView = [UIView new];
        _timeLineTableView.sectionIndexColor = [UIColor grayColor];
        _timeLineTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _timeLineTableView.tableHeaderView = self.tableViewHeaderView;
        [_timeLineTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TIMELINECELLIDENTIFIER];
    }
    return _timeLineTableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    startRefreshing = NO;
    isRefreshing = NO;
  
    //加载导航设置
    [self setUpNav];
    
    [self.timeLineTableView reloadData];
    [self.view addSubview:self.albumReflashImageView];
    [self.tableViewHeaderView addSubview:self.userFaceImageView];
}
-(void)setUpNav{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"朋友圈";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonicon_Camera"] style:UIBarButtonItemStylePlain target:self action:@selector(cameraBarButtonClick)];
    
}
-(void)cameraBarButtonClick{
    
}

#pragma mark -  faceImgeViewCick
-(void)faceImageViewClick{
    [self.view makeToast:@"头像"];
}


#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TIMELINECELLIDENTIFIER forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"index %li",indexPath.row];
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGPoint point = scrollView.contentOffset;
    
    if (point.y<0) {
        
        if (isRefreshing) {
            return;
        }
        
      
        CGFloat rate  = point.y/10;
        CGFloat centerY = REFLSAHINITCENTERY+fabs(point.y)-STATUS_AND_NAV_BAR_HEIGHT;
        
        if (centerY>REFLASHMAXCENTERY) {
            
            self.albumReflashImageView.centerY = REFLASHMAXCENTERY;
            
            startRefreshing = YES;
        }else{
            self.albumReflashImageView.centerY = centerY;
            startRefreshing = NO;
        }
        //旋转刷新图标
        self.albumReflashImageView.transform = CGAffineTransformMakeRotation(rate);
    }
    
 

    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (startRefreshing) {
        [self startRotate];
    }else{
        self.albumReflashImageView.centerY = REFLSAHINITCENTERY;
        
    }

}


/*
 
 下面来讲各个fillMode的意义
 kCAFillModeRemoved 这个是默认值,也就是说当动画开始前和动画结束后,动画对layer都没有影响,动画结束后,layer会恢复到之前的状态
 kCAFillModeForwards 当动画结束后,layer会一直保持着动画最后的状态
 kCAFillModeBackwards 这个和kCAFillModeForwards是相对的,就是在动画开始前,你只要将动画加入了一个layer,layer便立即进入动画的初始状态并等待动画开始.你可以这样设定测试代码,将一个动画加入一个layer的时候延迟5秒执行.然后就会发现在动画没有开始的时候,只要动画被加入了layer,layer便处于动画初始状态
 kCAFillModeBoth 理解了上面两个,这个就很好理解了,这个其实就是上面两个的合成.动画加入后开始之前,layer便处于动画初始状态,动画结束后layer保持动画最后的状态.
 
 */
-(void)startRotate{
    if (![self.albumReflashImageView.layer animationForKey:@"animation"]) {
     
        
        CABasicAnimation *animationImage = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animationImage.fromValue = [NSNumber numberWithFloat:0];
        animationImage.toValue = [NSNumber numberWithFloat:M_PI *2.0];
        animationImage.duration = 1;
        
        animationImage.repeatCount =HUGE_VALF;
        animationImage.fillMode = kCAFillModeForwards;
        [self.albumReflashImageView.layer addAnimation:animationImage forKey:@"animation"];
        
        [self performSelector:@selector(endRotate) withObject:nil afterDelay:2];
        
        isRefreshing = YES;
    }


}
-(void)endRotate{
    //上升隐藏
    [UIView animateWithDuration:0.2 animations:^{
        self.albumReflashImageView.centerY = REFLSAHINITCENTERY;
    } completion:^(BOOL finished) {
        startRefreshing = NO;
        isRefreshing = NO;
        [self.albumReflashImageView.layer removeAllAnimations];
    }];

    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end