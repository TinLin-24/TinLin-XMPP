//
//  TLMessageMediaModel.h
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/20.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    TLMessageMediaNone,
    TLMessageMediaPhoto,
    TLMessageMediaLocation,
    TLMessageMediaVideo,
    TLMessageMediaAudio
} TLMessageMediaType;

@interface TLMessageMediaModel : NSObject

+ (id)fetchMediaItemWithType:(TLMessageMediaType)type Outgoing:(BOOL)outgoing Body:(NSString *)body;

+ (TLMessageMediaType)fetchMediaTypeWithExtension:(NSString *)extension;

@end
