import QtQuick 2.0
//import Ubuntu.Components 0.1
import "../js/getURL.js" as GetURL
import "../js/dateutils.js" as DateUtils
import Sailfish.Silica 1.0

 Item{
    id: usRepostWeiboContent
    anchors {
        left: parent.left
        right: parent.right
    }
    height: isInvalid ? 0 : columnWContent.height + Theme.paddingMedium
    //radius: "medium"
    //color: Qt.rgba(255, 255, 255, 0.3)

    property var retweetWeibo
    property bool isInvalid: retweetWeibo == undefined
//    property var itemPic: isInvalid ? { "null": null } : retweetWeibo.pic_urls

    signal retweetClicked

    Component.onCompleted: {
//        console.log("=========== usRepostWeiboContent isInvalid  " + isInvalid)
        if ( !isInvalid && retweetWeibo.pic_urls != undefined && retweetWeibo.pic_urls.length > 0) {
            modelImages.clear()
            for (var i=0; i<retweetWeibo.pic_urls.length; i++) {
                modelImages.append( retweetWeibo.pic_urls[i] )
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            var tmp = retweetWeibo.retweeted_status
           console.log("retweetWeibo.retweeted_status: ", JSON.stringify(tmp))
            
            usRepostWeiboContent.retweetClicked()
        }
    }

    Image {
        id: background
        anchors {
            top: usRepostWeiboContent.top
            left: usRepostWeiboContent.left
            right: usRepostWeiboContent.right
            bottom: usRepostWeiboContent.bottom
        }
        source: "../graphics/mask_background_reposted.png"
        fillMode:Image.TileHorizontally
    }
    
    Column {
        id: columnWContent
        anchors {
            top: parent.top
            topMargin: Theme.paddingSmall// 1//units.gu(1)
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingSmall//1// units.gu(1)
            rightMargin:Theme.paddingSmall//1// units.gu(1)
        }
        spacing: Theme.paddingSmall

        UserAvatarHeader {
            id:repostAvaterHeader
            width: parent.width *7/10
            height:Theme.itemSizeSmall
            visible: isInvalid
            
            userName: isInvalid ? "" : retweetWeibo.user.screen_name
            userNameFontSize: Theme.fontSizeExtraSmall
            userAvatar: isInvalid ? "" :retweetWeibo.user.profile_image_url
            weiboTime: isInvalid ? "" : 
                               DateUtils.formatRelativeTime( DateUtils.parseDate(appData.dateParse(retweetWeibo.created_at)))
                               + qsTr(" From ") +GetURL.linkToStr(retweetWeibo.source)

            onUserAvatarClicked: {
                console.log("======== DelegateReposted Weibo usAvatar clicked");
                toUserPage(retweetWeibo.user.id)
            }
        }
        
        Label {
            id: labelWeibo
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            //color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeSmall
            textFormat: Text.StyledText
            text: isInvalid ? "" : util.parseWeiboContent(model.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)//GetURL.replaceReg(retweetWeibo.text, Theme.highlightColor)

            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }

        Grid {
            id: gridWeiboPics
            columns: 3; spacing: Theme.paddingSmall;//2; /*visible: isInvalid ? false : retweetWeibo.pic_urls.count != 0*/
            //width: parent.width; height: childrenRect.height

            Repeater {
                model: ListModel { id: modelImages }
                delegate: Component {
                    Image{
                        id:image
                        fillMode: Image.PreserveAspectCrop;
                        width: modelImages.count == 1 ? implicitWidth : columnWContent.width / 3 - Theme.paddingSmall;//units.gu(3) ;
                        height: modelImages.count == 1 ? implicitHeight : width
                        source: util.parseImageUrl(model.thumbnail_pic)

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                toGalleryPage(modelImages, index)
                            }
                        }
                        
                        onStatusChanged: {
                            if(image.status == Image.Ready) {
                                util.saveRemoteImage(model.thumbnail_pic);
                            }
                        }
                    }
                }
            }

//            Image { source: itemPic[0] == undefined ? "" : itemPic[0].thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: itemPic[0] == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width  }
//            Image { source: itemPic[1] == undefined ? "" : itemPic[1].thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: itemPic[1] == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
//            Image { source: itemPic[2] == undefined ? "" : itemPic[2].thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: itemPic[2] == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
//            Image { source: itemPic[3] == undefined ? "" : itemPic[3].thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: itemPic[3] == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
//            Image { source: itemPic[4] == undefined ? "" : itemPic[4].thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: itemPic[4] == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
//            Image { source: itemPic[5] == undefined ? "" : itemPic[5].thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: itemPic[5] == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
//            Image { source: itemPic[6] == undefined ? "" : itemPic[6].thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: itemPic[6] == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
//            Image { source: itemPic[7] == undefined ? "" : itemPic[7].thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: itemPic[7] == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
//            Image { source: itemPic[8] == undefined ? "" : itemPic[8].thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: itemPic[8] == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
        }
    }


}
