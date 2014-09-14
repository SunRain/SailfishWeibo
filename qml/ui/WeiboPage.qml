import QtQuick 2.0
import Sailfish.Silica 1.0
//import QtQuick.XmlListModel 2.0
//import Ubuntu.Components 0.1
//import Ubuntu.Components.ListItems 0.1 as ListItem
//import Ubuntu.Components.Popups 0.1
import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

Page {
    //objectName: "weibofeedpage"
    id: weiboPage
    //title: qsTr("Weibo Content")
    //flickable: null

    signal articleStatusChanged(int tagId, int articleId, string status)
    signal articleFavouriteChanged(var article, string favourite)
    signal commentsWanted(var weiboId, int modelIndex)

    property string weiboModelUrl: ""
    property string weiboTitle: ""
    property var weiboModel
    property var newIndex
    property var weiboItem: null
    property bool preventIndexChangeHandler: false

    property var commentInfo

//    function setNewIndex(weiboIndex) {
//        weiboListview.currentIndex = weiboIndex
//        weiboListview.positionViewAtIndex(weiboListview.currentIndex, ListView.Center)
//    }

//    function setFeed(model, index) {
//        /* Setting new model and not-null index will cause two change events instead of one.
//         * Settings "preventIndexChangeHandler" to true helps to avoid it.
//         */
//        if (weiboModel != model && index !== 0)
//            preventIndexChangeHandler = true;
        
////        weiboPageLoader.sourceComponent = weiboPageLoader.Null;
////        weiboPageLoader.sourceComponent = weiboListviewComponent;
        
//        weiboModel = model
//        setNewIndex(index)
//    }

//    function reloadPageContent() {

//    }
    
//    Loader {
//        id:weiboPageLoader
//        anchors.fill: parent
//        sourceComponent: busyIndicatorComponent
//    }
    
//    Component{
//        id:busyIndicatorComponent
//        BusyIndicator {
//            id:busyIndicator
            
//            Component.onCompleted: {
//                setFeed(weiboModel,newIndex);
//            }
//        }
//    }

    //TODO:暂时移除
//    Component {
//        id: dialog
//        Dialog {
//            id: dialogue
//            //title: qsTr("Comment options")
//           // text: qsTr("Please choose one of the following options")

//            Button {
//                text: qsTr("Reply")
//                onClicked: {
//                    console.log("comment info: ", JSON.stringify(weiboPage.commentInfo))
//                    PopupUtils.close(dialogue)
//                    mainView.toSendPage("reply", weiboPage.commentInfo)
//                }
//            }
//            Button {
//                text: qsTr("Copy")
////                onClicked: PopupUtils.close(dialogue)
//            }
//            Button{
//                //gradient: UbuntuColors.greyGradient
//                text: qsTr("Cancel")
//                onClicked: PopupUtils.close(dialogue)
//            }
//        }
//    }


    //////////////////////////////////////////////      a listview to show the weibo content
    SilicaListView {
        id: weiboListview
        
        anchors.fill: parent     
        //                snapMode: ListView.SnapOneItem
        //                boundsBehavior: Flickable.StopAtBounds
        //                orientation: ListView.Horizontal
        contentHeight: parent.width * count
        model: weiboListviewModel//weiboModel
        delegate: xmlDelegate
        clip: true
        //currentIndex: -1;
        //                highlightFollowsCurrentItem: true
        //                highlightRangeMode: ListView.StrictlyEnforceRange
        
        onCurrentIndexChanged: {
            console.log("ListView onCurrentIndexChanged", currentIndex, preventIndexChangeHandler)
            console.log("listView weiboListviewModel count is " + /*weiboModel.count*/weiboListviewModel.count);
            if (preventIndexChangeHandler) {
                preventIndexChangeHandler = false
                return
            }
            
            /*if (weiboModel.count == 0)*/ // It is normal bevaviour.
            if (weiboListviewModel.count == 0)
                return
            
//            if (weiboModel == null || weiboModel.get == undefined) {
            if (weiboListviewModel == null || weiboListviewModel.get == undefined) {
                console.log("---- Stange behavior ----")
                console.trace()
                return
            }
            
            weiboItem = weiboListviewModel.get(currentIndex);//weiboModel.get(currentIndex)
            
            currentItem.getComments(Settings.getAccess_token(), weiboItem.id, 1)
            //            console.log("weiboItem: ", JSON.stringify(weiboItem))
            //            commentsWanted(weiboItem.id, currentIndex)
            
            //            weiboTitle = weiboItem.feed_name
            
            //            if (weiboItem.status != "1") {
            //                var dbResult = DB.updateArticleStatus(weiboItem.id, "1")
            //                if (dbResult.rowsAffected == 1) {
            //                    articleStatusChanged(weiboItem.tagId, weiboItem.id, "1")
            //                }
            //            }
        }
        
        Component.onCompleted: {
            console.log("== weiboPageSilicaFlickable onCompleted");
            weiboListviewModel.clear();
            weiboListviewModel.append(weiboModel.get(newIndex));
            weiboListview.currentIndex = 0//newIndex;
            weiboListview.positionViewAtIndex(weiboListview.currentIndex, ListView.Center);
            
        }
    }
    
    ListModel {
        id:weiboListviewModel
    }

    //////////////////////////////////////////////      delegate for ListView
    Component {
        id: xmlDelegate

        /*Flickable*/SilicaFlickable {
            id: scrollArea

//            clip: true
            boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds

            width: weiboListview.width
            height: weiboListview.height

            contentWidth: width
            contentHeight: innerAreaColumn.height

            property int weiboIndex: index

            //////////////////////////////////////////////////////////////////         get comments
            function getComments(token, id, page)
            {
                function observer() {}
                observer.prototype = {
                    update: function(status, result)
                    {
                        if(status != "error"){
                            if(result.error) {
                                // TODO  error handler
                            }else {
                                // right result
                                console.log("comments length: ", result.comments.length)
//                              console.log("comments : ", JSON.stringify(result))
                                modelComment.clear()
                                for (var i=0; i<result.comments.length; i++) {
                                    modelComment.append(result.comments[i])
                                }
                            }
                        }else{
                            // TODO  empty result
                        }
                    }
                }

                WB.weiboGetComments(token, id, page, new observer())
            }

            Column {
                id: innerAreaColumn

                spacing: Theme.paddingSmall//units.gu(2)
                anchors {
                    left: parent.left; right: parent.right
                    leftMargin: Theme.paddingSmall//units.gu(1)
                    rightMargin: Theme.paddingSmall//units.gu(1)
                }

                DelegateWeibo {
                    onClicked: {
                        console.log("WeiboPage ==== DelegateWeibo item clicked");
//                        console.log("model.pic_urls: ", JSON.stringify(pic_urls))
//                        var tmp = []
//                        if (model.pic_urls != undefined && model.pic_urls.count > 0) {
//                            for (var i=0; i<model.pic_urls.count; i++) {
//                                tmp.push(model.pic_urls.get(i))
//                            }
//                            mainView.toGalleryPage(tmp, 1)
//                        }
                    }
                }

                //////////////微博下面评论/转发的内容（listView展示）
                Item {
                    width: parent.width
                    height: childrenRect.height
                    //color: Qt.rgba(255, 255, 255, 0.2)

                    /*ListView*/SilicaListView {
                        width: parent.width
                        height: contentItem.childrenRect.height
                        interactive: false
                        clip: true
                        spacing:Theme.paddingSmall// units.gu(1)
                        model: ListModel { 
                            id: modelComment 
                        }
                        delegate: delegateComment
                    }
                }

                //////////////微博下面评论/转发的内容（listView的代理）
                Component {
                    id: delegateComment

                    Rectangle {
                        width: parent.width
                        height: childrenRect.height
                        color: Qt.rgba(255, 255, 255, 0.3)

                        Column {
                            id: columnWContent
                            anchors {
                                top: parent.top
                                topMargin: Theme.paddingSmall //units.gu(1)
                                left: parent.left
                                right: parent.right
                                leftMargin: Theme.paddingSmall //units.gu(1)
                                rightMargin: Theme.paddingSmall //units.gu(1)
                            }
                            spacing: Theme.paddingMedium //units.gu(1)

                            //height: rowUser.height + labelWeibo.height//childrenRect.height

                            ////////用户头像/姓名/评论发送时间
                            Row {
                                id: rowUser
                                anchors { 
                                    left: parent.left
                                    leftMargin: Theme.paddingSmall
                                    right: parent.right
                                    rightMargin: Theme.paddingSmall
                                }
                                spacing:Theme.paddingSmall
                                //height: usAvatar.height
                                height: rowUserColumn.height > 64 ? rowUserColumn.height : usAvatar.height

                                Item {
                                    id: usAvatar
                                    width: 48
                                    height: width
                                    Image {
                                        width: parent.width
                                        height: parent.height
                                        smooth: true
                                        fillMode: Image.PreserveAspectFit
                                        source: model.user.profile_image_url
                                    }
                                }

                                Column {
                                    id:rowUserColumn
                                    spacing: Theme.paddingSmall/2

                                    Label {
                                        id: labelUserName
                                        color: Theme.secondaryColor //"black"
                                        text: model.user.screen_name
                                        font.pixelSize: Theme.fontSizeTiny
                                    }

                                    Label {
                                        id: labelCommentTime
                                        color: Theme.secondaryColor // "grey"
                                        //TODO:添加微博的时间
                                        text: "weibo Time" /*{
                                            return DateUtils.formatRelativeTime(i18n, DateUtils.parseDate(appData.dateParse(model.created_at)))
                                        }*/
                                        font.pixelSize: Theme.fontSizeTiny
                                    }
                                }
                            }

                            /////////评论/转发内容
                            Label {
                                id: labelWeibo
                                //                                width: parent.width
//                                anchors {
//                                    left: parent.left
//                                    right: parent.right
//                                    margins: Theme.paddingSmall
//                                }
                                width: parent.width
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                text: model.text
                            }

//                            ListItem.ThinDivider {
//                                width: parent.width
//                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                //TODO:暂时移除此处
//                                weiboPage.commentInfo = { "id": weiboModel.get(weiboIndex).id, "cid": model.id}
//                                PopupUtils.open(dialog)
                                console.log("weiboPage ==== delegateComment click")
                            }
                        }
                    }
                }

            }
        } // Flickable
    } // Component

}
