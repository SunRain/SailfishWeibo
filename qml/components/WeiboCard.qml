import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/getURL.js" as GetURL
Item {
    id:weiboCard
    
    anchors {
        left: parent.left
        right: parent.right
    }
    height: columnWContent.height

    property var weiboJSONContent
    property alias optionMenu: usWeibo.optionMenu
    
    property var repostButtonColor
    property var commentButtonColor
    property var likeButtonColor
    
    signal repostedWeiboClicked
    signal usWeiboClicked
    signal avatarHeaderClicked(string userId)
    signal labelLinkClicked(string link)
    signal labelImageClicked(var modelImages, string index)
    signal commentButtonClicked
    signal repostButtonClicked
    signal likeButtonClicked

    Column {
        id: columnWContent
        anchors {
            top: parent.top
            topMargin: Theme.paddingSmall
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingLarge 
            rightMargin: Theme.paddingLarge 
        }
        spacing: Theme.paddingMedium
        BaseWeiboCard {
            id:usWeibo
            isInvalid: false
            avatarHeaderHeight: Theme.itemSizeSmall
            avaterHeaderFontSize: Theme.fontSizeExtraSmall
            avaterHeaderUserName: weiboJSONContent.user.screen_name
            avaterHeaderAvaterImage: weiboJSONContent.user.profile_image_url
            avaterHeaderWeiboTime: DateUtils.parseDate(appData.dateParse(weiboJSONContent.created_at))
                    + qsTr(" From ") + GetURL.linkToStr(weiboJSONContent.source)

            labelFontSize: Theme.fontSizeMedium
            labelContent: util.parseWeiboContent(weiboJSONContent.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
            picURLs: weiboJSONContent.pic_urls
            
            onUserAvatarHeaderClicked: {
                weiboCard.avatarHeaderClicked(weiboJSONContent.user.id);
            }
            onLabelLinkClicked: {
                weiboCard.labelLinkClicked(link);
            }
            onBaseWeiboCardClicked: {
                weiboCard.usWeiboClicked();
            }
            onLabelImageClicked: {
                weiboCard.labelImageClicked(modelImages, index);
            }
        }
        
        Loader{
            id:repostedLoader
            width: parent.width
            height: childrenRect.height
            sourceComponent: weiboJSONContent.retweeted_status == undefined 
                             ? repostedLoader.Null
                             : repostedBaseWeiboCard
        }

        Component {
            id:repostedBaseWeiboCard
            BaseWeiboCard {
                id:repostedWeibo
                isInvalid:  weiboJSONContent.retweeted_status == undefined
                avatarHeaderHeight: Theme.itemSizeSmall
                avaterHeaderFontSize: Theme.fontSizeExtraSmall
                avaterHeaderUserName: weiboJSONContent.retweeted_status.user.screen_name
                avaterHeaderAvaterImage: weiboJSONContent.retweeted_status.user.profile_image_url
                avaterHeaderWeiboTime: DateUtils.parseDate(appData.dateParse(weiboJSONContent.retweeted_status.created_at))
                        + qsTr(" From ") + GetURL.linkToStr(weiboJSONContent.retweeted_status.source)
                
                labelFontSize: Theme.fontSizeMedium
                labelContent: util.parseWeiboContent(weiboJSONContent.retweeted_status.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
                picURLs: weiboJSONContent.retweeted_status.pic_urls

                onUserAvatarHeaderClicked: {
                    weiboCard.avatarHeaderClicked(weiboJSONContent.retweeted_status.user.id);
                }
                onLabelLinkClicked: {
                    weiboCard.labelLinkClicked(link);
                }
                onBaseWeiboCardClicked: {
                    weiboCard.repostedWeiboClicked();
                }
                onLabelImageClicked: {
                    weiboCard.labelImageClicked(modelImages, index);
                }
                
                Image {
                    id: background
                    anchors {
                        top: repostedWeibo.top
                        left: repostedWeibo.left
                        right: repostedWeibo.right
                        bottom: repostedWeibo.bottom
                    }
                    source: util.pathTo("qml/graphics/mask_background_reposted.png")
                    fillMode:Image.TileHorizontally
                }
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            height: childrenRect.height

            Item {
                width: columnWContent.width / 3 -Theme.paddingSmall
                height: Theme.fontSizeSmall
                HorizontalIconTextButton {
                    id:repostButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    icon: util.pathTo("qml/graphics/repost.png")
                    text: weiboJSONContent.reposts_count
                    color: repostButtonColor == undefined ? Theme.secondaryColor : repostButtonColor
                    onClicked: {
                        weiboCard.repostButtonClicked();
                    }
                }
            }
            Rectangle {
                width: 1
                height: Theme.fontSizeSmall -2
                color: Theme.highlightColor
            }
            Item {
                width: columnWContent.width / 3 - Theme.paddingSmall
                height: Theme.fontSizeSmall
                HorizontalIconTextButton {
                    id:commentButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    icon: util.pathTo("qml/graphics/comment.png")
                    text: weiboJSONContent.comments_count
                    color: commentButtonColor == undefined ? Theme.secondaryColor : commentButtonColor
                    onClicked: {
                        weiboCard.commentButtonClicked();
                    }
                }
            }
            Rectangle {
                width: 1
                height: Theme.fontSizeSmall -2
                color: Theme.highlightColor
            }
            Item {
                width: columnWContent.width / 3 - Theme.paddingSmall
                height: Theme.fontSizeSmall
                HorizontalIconTextButton {
                    id:likeButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    icon: util.pathTo("qml/graphics/like.png")
                    text: weiboJSONContent.attitudes_count
                    color: likeButtonColor == undefined ? Theme.secondaryColor : likeButtonColor
                    onClicked: {
                        weiboCard.likeButtonClicked();
                    }
                }
            }
        }
    }
}
