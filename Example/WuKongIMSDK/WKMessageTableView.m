//
//  WKMessageTableView.m
//  WuKongIMSDK_Example
//
//  Created by tt on 2023/5/23.
//  Copyright © 2023 3895878. All rights reserved.
//

#import "WKMessageTableView.h"
#import <WuKongIMSDK/WuKongIMSDK.h>

#define maxWidth 250.0f

@implementation WKMessageTableView

- (void)reload {
    
}

@end


@interface WKTextCell : UITableViewCell

@property(nonatomic,strong) UILabel *contentLbl;
@property(nonatomic,strong) UIView *bubbleView;

@end

@implementation WKTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
   if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
       self.selectionStyle = UITableViewCellSelectionStyleNone;
      
       [self initUI];
   }
    return self;
}

-(void) initUI {
    [self setBackgroundColor:[UIColor clearColor]];
    self.contentView.userInteractionEnabled = YES;
    
    [self addSubview:self.bubbleView];
    [self.bubbleView addSubview:self.contentLbl];
}

-(void) refresh:(WKMessage*)message {
    WKTextContent *content = (WKTextContent*)message.content;
    
    self.contentLbl.text = content.content;
    [self.contentLbl sizeToFit];
}

-(void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentFrame = self.contentLbl.frame;
    
    self.bubbleView.frame = CGRectMake(0.0f, 0.0f, contentFrame.size.width, contentFrame.size.height);
}

- (UIView *)bubbleView {
    if(!_bubbleView) {
        _bubbleView = [[UIView alloc] init];
    }
    return _bubbleView;
}

- (UILabel *)contentLbl {
    if(!_contentLbl) {
        _contentLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, maxWidth, 0.0f)];
        _contentLbl.font = [UIFont systemFontOfSize:15.0f];
    }
    return _contentLbl;
}
@end
