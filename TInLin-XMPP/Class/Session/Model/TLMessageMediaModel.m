//
//  TLMessageMediaModel.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/20.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "TLMessageMediaModel.h"

#import <JSQPhotoMediaItem.h>
#import <JSQVideoMediaItem.h>
#import <JSQLocationMediaItem.h>
#import <JSQAudioMediaItem.h>

#import <JSQMessagesMediaPlaceholderView.h>

@interface TLMessageMediaModel ()

@end

@implementation TLMessageMediaModel

+ (id<JSQMessageMediaData>)fetchMediaItemWithType:(TLMessageMediaType)type Outgoing:(BOOL)outgoing Body:(NSString *)body {
 
    switch (type) {
        case TLMessageMediaNone:
            return nil;
            break;
        case TLMessageMediaPhoto:
        {
            NSString *path = TLDocumentDirectory;
            path = [path stringByAppendingPathComponent:body];
            NSData *imageData = [NSData dataWithContentsOfFile:path];
            UIImage *image = [UIImage imageWithData:imageData];
            JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:image];
            item.appliesMediaViewMaskAsOutgoing = outgoing;
            return item;
        }
            break;
        case TLMessageMediaLocation:
        {
            NSArray *locationArr = [body componentsSeparatedByString:@","];
            CGFloat latitude = [locationArr.firstObject floatValue];
            CGFloat longitude = [locationArr.lastObject floatValue];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude
                                                              longitude:longitude];
            JSQLocationMediaItem *item = [[JSQLocationMediaItem alloc] init];
            [item setLocation:location withCompletionHandler:^{
                //NSLog(@"");
            }];
            item.appliesMediaViewMaskAsOutgoing = outgoing;
            return item;
        }
            break;
        case TLMessageMediaVideo:
        {
            NSURL *filePath = [NSURL fileURLWithPath:[TLDocumentDirectory stringByAppendingPathComponent:body]];
            JSQVideoMediaItem *item = [[JSQVideoMediaItem alloc] initWithFileURL:filePath isReadyToPlay:YES];
            item.appliesMediaViewMaskAsOutgoing = outgoing;
            return item;
        }
            break;
        case TLMessageMediaAudio:
        {
            JSQAudioMediaItem *item = [[JSQAudioMediaItem alloc] initWithData:nil];
            item.appliesMediaViewMaskAsOutgoing = outgoing;
            return item;
        }
            break;
    }
}

+ (TLMessageMediaType)fetchMediaTypeWithExtension:(NSString *)extension {
    if ([@"png" isEqualToString:extension] || [@"jepg" isEqualToString:extension]) {
        return TLMessageMediaPhoto;
    }
    else if ([@"mp4" isEqualToString:extension] || [@"mov" isEqualToString:extension]) {
        return TLMessageMediaVideo;
    }
    else if ([@"mp3" isEqualToString:extension] || [@"wav" isEqualToString:extension]) {
        return TLMessageMediaAudio;
    }
    return TLMessageMediaNone;
}

@end
