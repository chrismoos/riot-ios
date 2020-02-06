/*
 Copyright 2016 OpenMarket Ltd
 Copyright 2017 Vector Creations Ltd

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "RoomEncryptedDataBubbleCell.h"

NSString *const kRoomEncryptedDataBubbleCellTapOnEncryptionIcon = @"kRoomEncryptedDataBubbleCellTapOnEncryptionIcon";

@implementation RoomEncryptedDataBubbleCell

+ (UIImage*)encryptionIconForEvent:(MXEvent*)event andSession:(MXSession*)session
{
    MXRoom *room = [session roomWithRoomId:event.roomId];
    BOOL isRoomEncrypted = room.summary.isEncrypted && session.crypto;
    
    if (!isRoomEncrypted)
    {
        return nil;
    }
    
    NSString *encryptionIconName;
    UIImage* encryptionIcon;
    
    if (!event.isEncrypted)
    {
        if (event.isLocalEvent
            || event.isState
            || event.contentHasBeenEdited)    // Local echo for an edit is clear but uses a true event id, the one of the edited event
        {
            encryptionIconName = nil;
        }
        else
        {
            encryptionIconName = @"encryption_warning";
        }
    }
    else if (event.decryptionError)
    {
        encryptionIconName = @"encryption_warning";
    }
    else if (event.sender)
    {
        MXUserTrustLevel *userTrustLevel = [session.crypto trustLevelForUser:event.sender];
        MXDeviceInfo *deviceInfo = [session.crypto eventDeviceInfo:event];
        
        if (userTrustLevel.isVerified && !deviceInfo.trustLevel.isVerified)
        {
            encryptionIconName = @"encryption_warning";
        }
    }
    
    if (encryptionIconName)
    {
         encryptionIcon = [UIImage imageNamed:encryptionIconName];
    }
    
    return encryptionIcon;
}

+ (void)addEncryptionStatusFromBubbleData:(MXKRoomBubbleCellData *)bubbleData inContainerView:(UIView *)containerView
{
    // Ensure that older subviews are removed
    // They should be (they are removed when the cell is not anymore used).
    // But, it seems that is not always true.
    NSArray* views = [containerView subviews];
    for (UIView* view in views)
    {
        [view removeFromSuperview];
    }
    
    NSArray *bubbleComponents = bubbleData.bubbleComponents;
    MXKRoomBubbleComponent *component;
    
    for (NSUInteger componentIndex = 0; componentIndex < bubbleComponents.count; componentIndex++)
    {
        component  = bubbleComponents[componentIndex];
        
        // Ignore components without display.
        if (!component.attributedTextMessage)
        {
            continue;
        }
    
        UIImage *icon = [RoomEncryptedDataBubbleCell encryptionIconForEvent:component.event andSession:bubbleData.mxSession];
        
        if (icon)
        {
            UIImageView *encryptStatusImageView = [[UIImageView alloc] initWithImage:icon];
            
            CGRect frame = encryptStatusImageView.frame;
            frame.origin.y = component.position.y + 3;
            encryptStatusImageView.frame = frame;
            
            CGPoint center = encryptStatusImageView.center;
            center.x = containerView.frame.size.width / 2;
            encryptStatusImageView.center = center;
            
            encryptStatusImageView.tag = componentIndex;
            
            [containerView addSubview:encryptStatusImageView];
        }        
    }
}

@end
