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

    signal repostedWeiboClicked
    signal usWeiboClicked
    signal avatarHeaderClicked(string userId)
    signal labelLinkClicked(string link)
    signal labelImageClicked(var modelImages, string index)
    

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
            avaterHeaderWeiboTime: DateUtils.formatRelativeTime(DateUtils.parseDate(appData.dateParse(weiboJSONContent.created_at)))
                                   + qsTr(" From ") + GetURL.linkToStr(weiboJSONContent.source)
            
            labelFontSize: Theme.fontSizeMedium
            labelContent: util.parseWeiboContent(weiboJSONContent.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
            picURLs: weiboJSONContent.pic_urls
            
            onUserAvatarHeaderClicked: {
                //toUserPage(weiboJSONContent.user.id);
                weiboCard.avatarHeaderClicked(weiboJSONContent.user.id);
            }
            onLabelLinkClicked: {
                 //Qt.openUrlExternally(link);
                weiboCard.labelLinkClicked(link);
            }
            onBaseWeiboCardClicked: {
                weiboCard.usWeiboClicked();
            }
            onLabelImageClicked: {
                //toGalleryPage(modelImages, index);
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
                avaterHeaderWeiboTime: DateUtils.formatRelativeTime(DateUtils.parseDate(appData.dateParse(weiboJSONContent.retweeted_status.created_at)))
                                       + qsTr(" From ") + GetURL.linkToStr(weiboJSONContent.retweeted_status.source)
                
                labelFontSize: Theme.fontSizeMedium
                labelContent: util.parseWeiboContent(weiboJSONContent.retweeted_status.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
                picURLs: weiboJSONContent.retweeted_status.pic_urls

                onUserAvatarHeaderClicked: {
                    //toUserPage(weiboJSONContent.retweeted_status.user.id);
                    weiboCard.avatarHeaderClicked(weiboJSONContent.retweeted_status.user.id);
                }
                onLabelLinkClicked: {
                    //Qt.openUrlExternally(link);
                    weiboCard.labelLinkClicked(link);
                }
                onBaseWeiboCardClicked: {
                    weiboCard.repostedWeiboClicked();
                }
                onLabelImageClicked: {
                    //toGalleryPage(modelImages, index);
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
                    source: "../graphics/mask_background_reposted.png"
                    fillMode:Image.TileHorizontally
                }
            }
        }
        
        Column {
            width: parent.width
            spacing: Theme.paddingSmall

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                
                Item {
                    width: columnWContent.width / 3 -Theme.paddingSmall 
                    height: Theme.fontSizeSmall
                    
                    Label {
                        anchors.centerIn: parent
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeTiny
                        text: qsTr("repost: ") + weiboJSONContent.reposts_count
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
                    
                    Label {
                        anchors.centerIn: parent
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeTiny
                        text: qsTr("comment: ") + weiboJSONContent.comments_count
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
                    
                    Label {
                        anchors.centerIn: parent
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeTiny
                        text: qsTr("like: ") + weiboJSONContent.attitudes_count
                    }
                }
            }
        }
    }
}
