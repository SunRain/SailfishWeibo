import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../components"

Page{
    id: commentMentionedPage
    title: i18n.tr("Comments mentioned me")

    property var uid
    property string userName: ""
    property int pageNum: 1

    property var commentInfo
    property var weiboTmp

    function refresh() {
        modelComment.clear()

        pageNum = 1
//        isRefresh = true
        commentMentioned(settings.getAccess_token(), pageNum)
    }

    function addMore() {
        pageNum++
        commentMentioned(settings.getAccess_token(), pageNum)
    }

    //////////////////////////////////////////////////////////////////         get all comment mentioned me
    function commentMentioned(token, page)
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
//                        console.log("all comment: ", JSON.stringify(result.comments[0]))
                        for (var i=0; i<result.comments.length; i++) {
                            modelComment.append( result.comments[i] )
                        }
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.messageGetCommentMentioned(token, page, new observer())
    }

    Component {
        id: dialog
        Dialog {
            id: dialogue
            title: i18n.tr("Comment options")
            text: i18n.tr("Please choose one of the following options")

            Button {
                text: i18n.tr("Reply")
                onClicked: {
                    console.log("comment info: ", JSON.stringify(commentMentionedPage.commentInfo))
                    PopupUtils.close(dialogue)
                    mainView.toSendPage("reply", commentMentionedPage.commentInfo)
                }
            }
            Button {
                text: i18n.tr("View weibo")
                onClicked: {
                    modelWeiboTemp.clear()
                    modelWeiboTemp.append(weiboTmp)
                    mainView.toWeiboPage(modelWeiboTemp, 0)
                    PopupUtils.close(dialogue)
                }
            }
            Button{
                gradient: UbuntuColors.greyGradient
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }

    ListView {
        anchors.fill: parent
        width: parent.width
        height: contentItem.childrenRect.height
//        clip: true
        spacing: units.gu(1)
        model: ListModel { id: modelComment }
        delegate: delegateComment
        cacheBuffer: 9999
    }


    Component {
        id: delegateComment

        Item {
            width: parent.width
            height: childrenRect.height

            Column {
                id: columnWContent
                anchors {
                    top: parent.top; topMargin: units.gu(0.5)
                    left: parent.left; right: parent.right
//                    leftMargin: units.gu(1); rightMargin: units.gu(1)
                }
                spacing: units.gu(0.5)
                height: childrenRect.height

                Row {
                    id: rowUser
                    anchors { left: parent.left; right: parent.right; leftMargin: units.gu(1); rightMargin: units.gu(1) }
                    spacing: units.gu(1)
                    height: usAvatar.height

                    UbuntuShape {
                        id: usAvatar
                        width: units.gu(4.5)
                        height: width
                        image: Image {
                            source: model.user.profile_image_url
                        }
                    }

                    Column {
                        spacing: units.gu(0.2)

                        Label {
                            id: labelUserName
                            color: "black"
                            text: model.user.screen_name
                        }

                        Label {
                            id: labelCommentTime
                            color: "grey"
                            text: {
                                return DateUtils.formatRelativeTime(i18n, DateUtils.parseDate(appData.dateParse(model.created_at)))
                            }
                        }
                    }
                }

                Label {
                    id: labelComment
                    anchors { left: parent.left; right: parent.right; leftMargin: units.gu(1); rightMargin: units.gu(1) }
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: "black"
                    text: model.text
                }

                // user weibo
                UbuntuShape {
                    id: usWeiboContent
                    anchors {
                        left: parent.left; right: parent.right
                        leftMargin: units.gu(1); rightMargin: units.gu(1)
                    }
                    height: colWeibo.height + units.gu(1.5)
                    radius: "medium"
                    color: Qt.rgba(255, 255, 255, 0.3)

                    // use reply_comment if reply_comment exist
                    property var status: model.status

                    signal clicked

                    Column {
                        id: colWeibo
                        anchors {
                            top: parent.top; topMargin: units.gu(1)
                            left: parent.left; right: parent.right
                            leftMargin: units.gu(1); rightMargin: units.gu(1)
                        }
                        spacing: units.gu(1)
                        height: childrenRect.height

                        Column {
                            id: colUser
                            anchors { left: parent.left; right: parent.right }
                            spacing: units.gu(0.5)
                            height: childrenRect.height

                            Label {
                                id: labelWeiboUserName
                                color: "black"
                                text: usWeiboContent.status.user.screen_name
                            }
                        }

                        Label {
                            id: labelWeibo
                            width: parent.width
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            color: "black"
                            text: usWeiboContent.status.text
                        }

                    } // column


                } // user weibo

                ListItem.ThinDivider {}
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
//                    console.log("reply comment: ", JSON.stringify(model.reply_comment))
                    commentMentionedPage.commentInfo = { "id": model.status.id, "cid": model.id}
                    commentMentionedPage.weiboTmp = model.status
                    PopupUtils.open(dialog)
                }
            }
        }
    }// component

    ListModel {
        id: modelWeiboTemp
    }

}
