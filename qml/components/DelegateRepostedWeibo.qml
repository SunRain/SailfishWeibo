import QtQuick 2.0
//import Ubuntu.Components 0.1
import "../js/getURL.js" as GetURL
import Sailfish.Silica 1.0

/*UbuntuShape*/ Rectangle{
    id: usWeiboContent
    anchors {
        left: parent.left; right: parent.right
//                    leftMargin: units.gu(1); rightMargin: units.gu(1)
    }
    height: isInvalid ? 0 : columnWContent.height + 2/* units.gu(2)*/
    //radius: "medium"
    color: Qt.rgba(255, 255, 255, 0.3)

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
//            var tmp = retweetWeibo.retweeted_status
//            console.log("retweetWeibo.retweeted_status: ", JSON.stringify(tmp))
        }
    }

    Column {
        id: columnWContent
        anchors {
            top: parent.top
            topMargin: 1//units.gu(1)
            left: parent.left
            right: parent.right
            leftMargin: 1// units.gu(1)
            rightMargin:1// units.gu(1)
        }
        spacing: 0.5;//units.gu(0.5)
        height: childrenRect.height
//            rowUser.height + labelWeibo.paintedHeight + gridWeiboPics.height + units.gu(1)

        Row {
            id: rowUser
            anchors { left: parent.left; right: parent.right }
            spacing: 0.5//units.gu(0.5)
            height: labelUserName.paintedHeight

//            UbuntuShape {
//                id: usAvatar
//                width: units.gu(6)
//                height: width
//                image: Image {
//                    source: retweetWeibo.user.profile_image_url
//                }
//            }

            Label {
                id: labelUserName
                color: "black"
                text: isInvalid ? "" : retweetWeibo.user.screen_name

                MouseArea {
                    anchors.fill: parent
                    onClicked: mainView.toUserPage(retweetWeibo.user.id)
                }
            }
        }

        Label {
            id: labelWeibo
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "black"
            text: isInvalid ? "" : GetURL.replaceReg(retweetWeibo.text)

            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }

        Grid {
            id: gridWeiboPics
            columns: 3; spacing: 2; /*visible: isInvalid ? false : retweetWeibo.pic_urls.count != 0*/
            width: parent.width; height: childrenRect.height

            Repeater {
                model: ListModel { id: modelImages }
                delegate: Component {
                    Image {
                        fillMode: Image.PreserveAspectCrop;
                        width: modelImages.count == 1 ? implicitWidth : columnWContent.width / 3 - 3;//units.gu(3) ;
                        height: modelImages.count == 1 ? implicitHeight : width
                        source: model.thumbnail_pic

                        MouseArea {
                            anchors.fill: parent
                            onClicked: mainView.toGalleryPage(modelImages, index)
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
