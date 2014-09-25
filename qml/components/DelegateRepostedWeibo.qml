import QtQuick 2.0
//import Ubuntu.Components 0.1
import "../js/getURL.js" as GetURL
import "../js/dateutils.js" as DateUtils
import Sailfish.Silica 1.0

 Item{
    id: usWeiboContent
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
            usWeiboContent.retweetClicked()
            var tmp = retweetWeibo.retweeted_status
           console.log("retweetWeibo.retweeted_status: ", JSON.stringify(tmp))
        }
    }

    Image {
        id: background
        anchors {
            top: parent.top
            topMargin: Theme.paddingSmall// 1//units.gu(1)
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingSmall//1// units.gu(1)
            rightMargin:Theme.paddingSmall//1// units.gu(1)
        }
        source: "../graphics/mask_background_reposted.png"
        fillMode:Image.PreserveAspectCrop
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

        Row {
            id: rowUser
            spacing: Theme.paddingMedium

            Item {
                id: usAvatar
                width: 48
                height: width
                Image {
                    width: parent.width
                    height: parent.height
                    smooth: true
                    fillMode: Image.PreserveAspectFit
                    source: isInvalid ? "" :retweetWeibo.user.profile_image_url
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        toUserPage(retweetWeibo.user.id)
                    }
                }
            }
            Column {
                id:rowUserColumn
                spacing: Theme.paddingSmall
                
                Label {
                    id: labelUserName
                    color: Theme.highlightColor
                    text: isInvalid ? "" : retweetWeibo.user.screen_name
                    font.pixelSize: Theme.fontSizeTiny 
                }
                Label {
                    id: labelWeiboTime
                    color: Theme.secondaryColor
                    text:isInvalid ? "" : 
                        DateUtils.formatRelativeTime( DateUtils.parseDate(appData.dateParse(retweetWeibo.created_at)))
                                     + qsTr(" From ") +GetURL.linkToStr(retweetWeibo.source)
                    font.pixelSize: Theme.fontSizeTiny 
                }
            }
        }

        Label {
            id: labelWeibo
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeSmall
            text: isInvalid ? "" : GetURL.replaceReg(retweetWeibo.text, Theme.highlightColor)

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
                    Image {
                        fillMode: Image.PreserveAspectCrop;
                        width: modelImages.count == 1 ? implicitWidth : columnWContent.width / 3 - Theme.paddingSmall;//units.gu(3) ;
                        height: modelImages.count == 1 ? implicitHeight : width
                        source: model.thumbnail_pic

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                toGalleryPage(modelImages, index)
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
