import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../js/dateutils.js" as DateUtils
import "../js/getURL.js" as GetURL

UbuntuShape {
    id: usWeiboContent
    anchors {
        left: parent.left; right: parent.right
//                    leftMargin: units.gu(1); rightMargin: units.gu(1)
    }
    height: columnWContent.height + units.gu(1.5)
    radius: "medium"
    color: Qt.rgba(255, 255, 255, 0.3)

    signal clicked

    Component.onCompleted: {
//        if (model.retweeted_status) {
////            var compo = Qt.createComponent("./DelegateRepostedWeibo.qml")
//            var retweet = parentView.itemRetweet.createObject(itemRetweetContainer, { /*"parentView": view, */"retweetWeibo": model.retweeted_status })
//        }
        if (model.pic_urls != undefined && model.pic_urls.count > 0) {
            modelImages.clear()
            for (var i=0; i<model.pic_urls.count; i++) {
                modelImages.append( model.pic_urls.get(i) )
//                workerImages.sendMessage( { "model": modelImages, "pic_urls": model.pic_urls.get(i) } )
            }
//            workerImages.sendMessage( { /*model: modelImages, */"pic_urls": pic_urls.get(0) } )
        }
    }

//    WorkerScript {
//        id: workerImages
//        source: "../js/addImages.js"

////        onMessage: console.log("addImages.js done: ", messageObject.reply)
//    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            usWeiboContent.clicked()
//            var tmp = model.pic_urls
//            console.log("model.pic_urls: ", JSON.stringify(tmp), gridWeiboPics.height, itemRetweetContainer.height)
        }
    }

    Column {
        id: columnWContent
        anchors {
            top: parent.top; topMargin: units.gu(1)
            left: parent.left; right: parent.right
            leftMargin: units.gu(1); rightMargin: units.gu(1)
        }
        spacing: units.gu(1)
        height: childrenRect.height
            /*rowUser.height + labelWeibo.paintedHeight + gridWeiboPics.height + itemRetweetContainer.height + units.gu(1.5)*/

        Row {
            id: rowUser
            anchors { left: parent.left; right: parent.right }
            spacing: units.gu(0.5)
            height: usAvatar.height

            UbuntuShape {
                id: usAvatar
                width: units.gu(6)
                height: width
                image: Image {
                    source: model.user.profile_image_url
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: mainView.toUserPage(model.user.id)
                }
            }

            Column {
                spacing: units.gu(1)

                Label {
                    id: labelUserName
                    color: "black"
                    text: model.user.screen_name
                }

                Label {
                    id: labelWeiboTime
                    color: "grey"
                    text: {
//                        console.log("appData.dateParse(model.created_at): ", appData.dateParse(model.created_at))
//                        var ddd = new Date(appData.dateParse(model.created_at) + "")
//                        console.log("ddd: ", ddd.getTime())
                        return DateUtils.formatRelativeTime(i18n, DateUtils.parseDate(appData.dateParse(model.created_at)))
                    }
                }
            }
        }

        Label {
            id: labelWeibo
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "black"
            text: GetURL.replaceReg(model.text)

            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }

        Grid {
            id: gridWeiboPics
            columns: 3; spacing: units.gu(0.5); /*visible: model.pic_urls == undefined ? false : model.pic_urls.count != 0*/
            width: parent.width; height: childrenRect.height
            
            Repeater {
                model: ListModel { id: modelImages }
                delegate: Component {
                    Image {
                        fillMode: Image.PreserveAspectCrop;
                        width: modelImages.count == 1 ? implicitWidth : columnWContent.width / 3 - units.gu(3) ;
                        height: modelImages.count == 1 ? implicitHeight : width
                        source: model.thumbnail_pic

                        MouseArea {
                            anchors.fill: parent
                            onClicked: mainView.toGalleryPage(modelImages, index)
                        }
                    }
                }
            }

//            Image { source: model.pic_urls.get(0) == undefined ? "" : model.pic_urls.get(0).thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: model.pic_urls.get(0) == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width  }
//            Image { source: model.pic_urls.get(1) == undefined ? "" : model.pic_urls.get(1).thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: model.pic_urls.get(1) == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
//            Image { source: model.pic_urls.get(2) == undefined ? "" : model.pic_urls.get(2).thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: model.pic_urls.get(2) == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
//            Image { source: model.pic_urls.get(3) == undefined ? "" : model.pic_urls.get(3).thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: model.pic_urls.get(3) == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
//            Image { source: model.pic_urls.get(4) == undefined ? "" : model.pic_urls.get(4).thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: model.pic_urls.get(4) == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
//            Image { source: model.pic_urls.get(5) == undefined ? "" : model.pic_urls.get(5).thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: model.pic_urls.get(5) == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
//            Image { source: model.pic_urls.get(6) == undefined ? "" : model.pic_urls.get(6).thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: model.pic_urls.get(6) == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
//            Image { source: model.pic_urls.get(7) == undefined ? "" : model.pic_urls.get(7).thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: model.pic_urls.get(7) == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
//            Image { source: model.pic_urls.get(8) == undefined ? "" : model.pic_urls.get(8).thumbnail_pic; fillMode: Image.PreserveAspectCrop
//                width: model.pic_urls.get(8) == undefined ? 0 : columnWContent.width / 4 - units.gu(3); height: width }
        }

        Item {
            id: itemRetweetContainer
            anchors {
                left: parent.left; right: parent.right
                leftMargin: units.gu(1); rightMargin: units.gu(1)
            }
            height: childrenRect.height
//                model.retweeted_status != undefined ? childrenRect.height : 0

            DelegateRepostedWeibo{
                visible: model.retweeted_status != undefined
                retweetWeibo: model.retweeted_status

                onRetweetClicked: usWeiboContent.clicked()
            }
        }

        Column {
            width: parent.width; height: childrenRect.height
            ListItem.ThinDivider { }

            Row {
                width: childrenRect.width; height: childrenRect.height
                anchors.horizontalCenter: parent.horizontalCenter

                Item {
                    width: columnWContent.width / 3 - units.gu(0.5);  height: units.gu(4)

                    Label {
                        anchors.centerIn: parent
                        color: "black"
                        text: i18n.tr("repost: ") + model.reposts_count
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            mainView.toSendPage("repost", {"id": model.id})
                        }
                    }
                }
                Rectangle {y: units.gu(0.2); width: units.gu(0.1); height: units.gu(3.5); color: "grey"}
                Item {
                    width: columnWContent.width / 3 - units.gu(0.5);  height: units.gu(4)

                    Label {
                        anchors.centerIn: parent
                        color: "black"
                        text: i18n.tr("comment: ") + model.comments_count
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            mainView.toSendPage("comment", {"id": model.id})
                        }
                    }
                }
                Rectangle {y: units.gu(0.2); width: units.gu(0.1); height: units.gu(3.5); color: "grey"}
                Item {
                    width: columnWContent.width / 3 - units.gu(0.5);  height: units.gu(4)

                    Label {
                        anchors.centerIn: parent
                        color: "black"
                        text: i18n.tr("like: ") + model.attitudes_count
                    }
                }
            }
        }
    }


}
