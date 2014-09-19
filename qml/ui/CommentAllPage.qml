import QtQuick 2.0
//import QtQuick.XmlListModel 2.0
//import Ubuntu.Components 0.1
//import Ubuntu.Components.ListItems 0.1 as ListItem
//import Ubuntu.Components.Popups 0.1
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

Page {
    id: commentAllPage
    //title: qsTr("All comments")

    property var uid
    property string userName: ""
    property int pageNum: 1

    property var commentInfo
    property var weiboTmp

    function refresh() {
        modelComment.clear()

        pageNum = 1
//        isRefresh = true
        commentAll(Settings.getAccess_token(), pageNum)
    }

    function addMore() {
        pageNum++
        commentAll(Settings.getAccess_token(), pageNum)
    }

    //////////////////////////////////////////////////////////////////         get all comment
    function commentAll(token, page)
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
//                        console.log("all comment: ", JSON.stringify(result))
                        for (var i=0; i<result.comments.length; i++) {
                            modelComment.append( result.comments[i] )
                        }
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.messageGetAllComment(token, page, new observer())
    }
    Component.onCompleted: {
        refresh();
    }

    Component {
        id: dialog
        Dialog {
            id: dialogue
            //title: qsTr("Comment options")
            //text: qsTr("Please choose one of the following options")

            Button {
                text: qsTr("Reply")
                onClicked: {
                    console.log("comment info: ", JSON.stringify(commentAllPage.commentInfo))
                    PopupUtils.close(dialogue)
                    mainView.toSendPage("reply", commentAllPage.commentInfo)
                }
            }
            Button {
                text: qsTr("View weibo")
                onClicked: {
                    modelWeiboTemp.clear()
                    modelWeiboTemp.append(weiboTmp)
                    mainView.toWeiboPage(modelWeiboTemp, 0)
                    PopupUtils.close(dialogue)
                }
            }
            Button{
                //gradient: UbuntuColors.greyGradient
                text: qsTr("Cancel")
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }

    SilicaListView {
        anchors.fill: parent
        //width: parent.width
        //height: contentItem.childrenRect.height
//        clip: true
       // spacing: 1//units.gu(1)
        model: ListModel { id: modelComment }
        delegate: delegateComment
        cacheBuffer: 9999
        header:PageHeader {
            id:pageHeader
            title: qsTr("All comments")
        }
    }


    Component {
        id: delegateComment

        /*Item*/ListItem {
           // width: parent.width
            //height: childrenRect.height
            width: parent.width
            contentHeight: columnWContent.height + Theme.paddingMedium 
            //color: Qt.rgba(255, 255, 255, 0.3)

            //menu: contextMenu

            Column {
                id: columnWContent
                anchors {
                    top: parent.top
                    topMargin: Theme.paddingMedium//0.5//units.gu(0.5)
                    left: parent.left
                    right: parent.right
//                    leftMargin: units.gu(1); rightMargin: units.gu(1)
                }
                spacing: Theme.paddingMedium
                //height: childrenRect.height

                Row {
                    id: rowUser
                    anchors { 
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingSmall 
                        rightMargin:Theme.paddingSmall 
                    }
                    spacing:Theme.paddingSmall 
                    height: owUserColumn.height > 64 ? rowUserColumn.height : usAvatar.height//usAvatar.height

                    Item{
                        id: usAvatar
                        width: 64//units.gu(4.5)
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
                        spacing: Theme.paddingSmall

                        Label {
                            id: labelUserName
                            color: Theme.primaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: model.user.screen_name
                        }

                        Label {
                            id: labelCommentTime
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text:"Weibo Time" /*{
                                return DateUtils.formatRelativeTime(i18n, DateUtils.parseDate(appData.dateParse(model.created_at)))
                            }*/
                        }
                    }
                }

                Label {
                    id: labelComment
                    anchors { 
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingSmall 
                        rightMargin: Theme.paddingSmall 
                    }
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    text: model.text
                }

                // user weibo
                Item {
                    id: usWeiboContent
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingSmall 
                        rightMargin: Theme.paddingSmall 
                    }
                    height: colWeibo.height + Theme.paddingSmall //1.5//units.gu(1.5)
                    // use reply_comment if reply_comment exist
                    property var status: model.reply_comment == undefined ? model.status : model.reply_comment

                    signal clicked

                    Image {
                        id: background
                        source: "../graphics/mask_background_reposted.png"
                        fillMode: Image.PreserveAspectCrop
                    }
                    
                    Column {
                        id: colWeibo
                        anchors {
                            top: parent.top
                            topMargin:Theme.paddingSmall 
                            left: parent.left
                            right: parent.right
                            leftMargin: Theme.paddingSmall 
                            rightMargin: Theme.paddingSmall 
                        }
                        spacing:Theme.paddingSmall 
                        //height: childrenRect.height

                        Column {
                            id: colUser
                            anchors { left: parent.left; right: parent.right }
                            spacing: Theme.paddingSmall 
                            height: childrenRect.height

                            Label {
                                id: labelWeiboUserName
                                color: Theme.secondaryHighlightColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                text: usWeiboContent.status.user.screen_name
                            }
                        }

                        Label {
                            id: labelWeibo
                            width: parent.width
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            text: usWeiboContent.status.text
                        }

                    } // column
                } // user weibo
                
                Separator {
                    width: parent.width
                    color: Theme.highlightColor
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
//                    console.log("reply comment: ", JSON.stringify(model.reply_comment))
                    commentAllPage.commentInfo = { "id": model.status.id, "cid": model.id}
                    commentAllPage.weiboTmp = model.status
                    //PopupUtils.open(dialog)
                }
            }
        }
    }// component

    ListModel {
        id: modelWeiboTemp
    }

}
