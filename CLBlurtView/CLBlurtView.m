//
//  CLBlurtView.m
//  CLBlurtView
//
//  Created by Charles on 15/12/23.
//  Copyright © 2015年 Charles. All rights reserved.
//

#import "CLBlurtView.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+LBBlurredImage.h"

#define changeRate  (self.frame.size.width / self.frame.size.height)

@interface CLBlurtView()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
/**
 *  图片
 */
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UIImageView *headImage;

@property (nonatomic,strong)UITableView *mTableView;
/**
 *  自定义添加的view
 */
@property (nonatomic,strong)UIView *otherView;
/**
 *  放大比例
 */
@property (nonatomic,assign)CGFloat scale;
/**
 *  名字label
 */
@property (nonatomic,strong)UILabel *label;

@end

@implementation CLBlurtView

- (instancetype)initWithFrame:(CGRect)frame WithHeaderImgHeight:(CGFloat)headerImgHeight iconHeight:(CGFloat)iconHeight selectBlock:(SelectRowAction)block {
    if (self = [super initWithFrame:frame]) {
        self.headerImgHeight = (headerImgHeight == 0  ? self.frame.size.height * 0.382 : headerImgHeight);
        self.iconHeight = (iconHeight == 0  ? self.frame.size.height * 0.382  : iconHeight);
        [self setupContentView];
        selectAction = block;
        
    }
    return self;
}
- (void)setupContentView {
    
    NSAssert(self.headerImgHeight >= self.iconHeight && self.iconHeight > 0, @"图片高度应当大于头像高度，头像高度应当大于零");
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.headerImgHeight)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView = imageView;
    self.scale =  self.imageView.frame.size.width / self.imageView.frame.size.height;
    UIImage *image = [UIImage imageNamed:@"1.jpg"];
    imageView.image = image;
    // 20 左右 R  模糊图片
    [imageView setImageToBlur:imageView.image blurRadius:21 completionBlock:nil];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - self.iconHeight) / 2, (self.headerImgHeight - self.iconHeight) / 2, self.iconHeight, self.iconHeight)];
    
    icon.backgroundColor = [UIColor yellowColor];
    NSLog(@"%@",NSStringFromCGRect(icon.frame));
    
    icon.image = [UIImage imageNamed:@"1.jpg"];
    icon.layer.cornerRadius = self.iconHeight * 0.5;
    icon.clipsToBounds = YES;
    self.headImage = icon;
    
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:self.imgUrl] placeholderImage:[UIImage imageNamed:@"1.jpg"]];
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.imgUrl] placeholderImage:[UIImage imageNamed:@"1.jpg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        // 20 左右 R  模糊图片
        [imageView setImageToBlur:imageView.image blurRadius:21 completionBlock:nil];
    }];
    
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(icon.frame) + 10, self.frame.size.width, 20)];
    self.label = name;
    name.text = (self.name ? self.name : @"Charles");
    name.textAlignment = NSTextAlignmentCenter;
    name.textColor = [UIColor whiteColor];
    UIView *otherVIew = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerImgHeight, self.frame.size.width,self.imageView.frame.size.height)];
    otherVIew.backgroundColor = [UIColor clearColor];
    self.otherView = otherVIew;
    [self.otherView addSubview:self.headImage];
    
    [self.otherView addSubview:self.label];
    // 注意添加顺序
    self.mTableView.tableHeaderView = imageView;
    [self addSubview:imageView];
    
    self.mTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    NSLog(@"%@",NSStringFromCGRect(self.frame));
    self.mTableView.backgroundColor = [UIColor clearColor];
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
    self.mTableView.decelerationRate = 2;
    [self addSubview:self.mTableView];
    self.mTableView.tableHeaderView = self.otherView;
}
#pragma mark -UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * strID = @"ID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:strID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%zi行",indexPath.row+1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectAction(indexPath);
}

#pragma mark - UIScrollViewDelgate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (scrollView.contentOffset.y < 0) {
        // 高度宽度同时拉伸 从中心放大
        CGFloat imgH = self.headerImgHeight - scrollView.contentOffset.y * 2;
        CGFloat imgW = imgH * self.scale;
        self.imageView.frame = CGRectMake(scrollView.contentOffset.y * self.scale,0, imgW,imgH);
        
        CGFloat iconOriginalX = (self.frame.size.width - self.iconHeight) / 2;
        CGFloat iconOriginalY = (self.headerImgHeight - self.iconHeight) / 2;
        
        self.headImage.frame = CGRectMake(iconOriginalX + offsetY * changeRate, iconOriginalY + offsetY * changeRate * 2, self.iconHeight - changeRate * offsetY * 2, self.iconHeight - changeRate * offsetY * 2);
        self.headImage.layer.cornerRadius = self.headImage.frame.size.width * 0.5;
        self.headImage.clipsToBounds = YES;
        
        self.label.frame = CGRectMake(self.label.frame.origin.x, CGRectGetMaxY(self.headImage.frame) + 10, self.label.frame.size.width, self.label.frame.size.height);
        if (scrollView.contentOffset.y > -64) {
            [UIView animateWithDuration:0.35 animations:^{
                self.superVC.navigationController.navigationBar.frame = CGRectMake(0, -64, self.frame.size.width, 64);
            }];
        }

    } else {
        // 只拉伸高度
        self.imageView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, 200 - scrollView.contentOffset.y);
        [UIView animateWithDuration:0.35 animations:^{
            if (scrollView.contentOffset.y > 64) {
                self.superVC.navigationController.navigationBarHidden = NO;
                self.superVC.navigationController.navigationBar.frame = CGRectMake(0, 0, self.frame.size.width, 64);
                [[UINavigationBar appearance] setTintColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
            }
        }];
    }
    NSLog(@"offset is:%0.0f",scrollView.contentOffset.y);
}


@end
