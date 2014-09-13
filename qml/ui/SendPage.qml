import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../js/weiboapi.js" as WB

Page {
    id: sendPage
//    title: i18n.tr("Send Weibo")
    flickable: null

    property string mode: ""
    property var repostType: [i18n.tr("No comments"), i18n.tr("Comment current Weibo"), i18n.tr("Comment original Weibo"), i18n.tr("Both")]
    property var commentType: [i18n.tr("Do not comment original Weibo"), i18n.tr("Also comment original Weibo")]

    property string sendTitle
    property var info         // include id, cid, etc..
    property string imgPath: ""

    //////////////////////////////////////////////////////////////////         set mode
    function setMode(mode, info)
    {
        sendPage.mode = mode
        sendPage.info = info
        switch (mode) {
        case "repost" :
            sendTitle = i18n.tr("Repost")
            selectorType.values = repostType
            break
        case "comment" :
            sendTitle = i18n.tr("Comment")
            selectorType.values = commentType
            break
        case "reply" :
            sendTitle = i18n.tr("Reply")
            selectorType.values = commentType
            break
        default:
            sendPage.mode = ""
            sendTitle = i18n.tr("Send Weibo")
            selectorType.values = [""]
            break
        }
    }

    //////////////////////////////////////////////////////////////////         send weibo
    function sendStatus(token, status)
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
                        if (result.id != undefined) {
                            mainView.addNotification(i18n.tr("New Weibo sent"), 3)
                            pageStack.pop()
                        }
                    }
                }else{
                    // TODO  empty result
                    mainView.addNotification(i18n.tr("Oops.. something wrong"), 3)
                }
            }
        }

        WB.weiboSendStatus(token, status, new observer())
    }

    // Connections for upload image
    Connections {
        id: connNetworkHelper
        target: networkHelper

        onUploadFinished: {
            var reply = JSON.parse(response)
            if (reply.error) {
                mainView.addNotification(i18n.tr("Oops.. something wrong"), 3)
            }
            else {
                if (reply.id != undefined) {
                    mainView.addNotification(i18n.tr("New Weibo sent"), 3)
                    pageStack.pop()
                }
            }
        }
    }

    //////////////////////////////////////////////////////////////////         send repost
    // is_comment 是否在转发的同时发表评论，0：否、1：评论给当前微博、2：评论给原微博、3：都评论，默认为0 。
    function repostStatus(token, status, id, is_comment)
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
                        if (result.id != undefined) {
                            mainView.addNotification(i18n.tr("Repost sent"), 3)
                            pageStack.pop()
                        }
                    }
                }else{
                    // TODO  empty result
                    mainView.addNotification(i18n.tr("Oops.. something wrong"), 3)
                }
            }
        }

        WB.weiboRepostStatus(token, status, id, is_comment, new observer())
    }

    //////////////////////////////////////////////////////////////////         send comment
    // id 需要评论的微博ID。  // comment_ori 当评论转发微博时，是否评论给原微博，0：否、1：是，默认为0。
    function sendComment(token, comment, id, comment_ori)
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
                        if (result.id != undefined) {
                            mainView.addNotification(i18n.tr("Comment sent"), 3)
                            pageStack.pop()
                        }
                    }
                }else{
                    // TODO  empty result
                    mainView.addNotification(i18n.tr("Oops.. something wrong"), 3)
                }
            }
        }

        WB.weiboSendComment(token, comment, id, comment_ori , new observer())
    }

    //////////////////////////////////////////////////////////////////         reply comment
    // id, comment_ori same above // commentid 需要回复的评论ID。  without_mention 回复中是否自动加入“回复@用户名”，0：是、1：否，默认为0。
    function replyComment(token, comment, id, comment_ori, commentid, without_mention)
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
                        if (result.id != undefined) {
                            mainView.addNotification(i18n.tr("Reply sent"), 3)
                            pageStack.pop()
                        }
                    }
                }else{
                    // TODO  empty result
                    mainView.addNotification(i18n.tr("Oops.. something wrong"), 3)
                }
            }
        }

        WB.weiboReplyComment(token, comment, id, comment_ori, commentid, without_mention , new observer())
    }

    //////////////////////////////////////////////////////////////////         set img path
    function setImgPath(filePath) {
        console.log("filePath: ", filePath)
        imgPath = filePath
//        mainStack.pop()
    }

    //////////////////////////////////////////////////////////////////         header
    Rectangle {
        id: recHeader
        anchors { left: parent.left; right: parent.right }
        height: btnCancel.height + units.gu(2)
        color: Qt.rgba(255, 255, 255, 0.2)

        Label {
            id: labelTitle
            anchors.centerIn: parent
            fontSize: "large"
            color: "black"
            text: sendTitle
        }

        Button{
            id: btnCancel
            anchors {
                left: parent.left; leftMargin: units.gu(1)
                verticalCenter: parent.verticalCenter
            }
            gradient: UbuntuColors.greyGradient
            text: i18n.tr("Cancel")

            onClicked: {
                pageStack.pop()
            }
        }

        Button{
            id: btnSend
            anchors {
                right: parent.right; rightMargin: units.gu(1)
                verticalCenter: parent.verticalCenter
            }
            text: i18n.tr("Send")

            onClicked: {
                switch (sendPage.mode) {
                case "repost" :
                    repostStatus(settings.getAccess_token(), textSendContent.text, info.id, selectorType.selectedIndex)
                    break
                case "comment" :
                    sendComment(settings.getAccess_token(), textSendContent.text, info.id, selectorType.selectedIndex)
                    break
                case "reply" :
                    replyComment(settings.getAccess_token(), textSendContent.text, info.id, selectorType.selectedIndex, info.cid, 0)
                    break
                default:
                    if (imgPath == "" || imgPath == undefined) {
                        sendStatus(settings.getAccess_token(), textSendContent.text)
                    }
                    else {
                        mainView.addNotification(i18n.tr("Uploading, please wait.."), 2)
                        var status = encodeURIComponent(textSendContent.text)
                        networkHelper.uploadImgStatus(settings.getAccess_token(), status, imgPath)
                    }
                    break
                }
            }
        }
    }


    //////////////////////////////////////////////////////////////////         content
    Column {
        id: colContent
        anchors {
//            fill: parent
            top: recHeader.bottom;  topMargin: units.gu(1)
            left: parent.left; right: parent.right
            leftMargin: units.gu(1); rightMargin: units.gu(1)
            bottomMargin: Qt.inputMethod.keyboardRectangle.height
        }
        spacing: units.gu(1)

        TextArea {
            id: textSendContent
            width: parent.width
            height: units.gu(16)
        }

        Row {
            height: /*childrenRect.height*/ units.gu(6)
            spacing: units.gu(1)

            Button {
                anchors.verticalCenter: parent.verticalCenter
                text: "@Someone"
                onClicked: PopupUtils.open(componentAtSheet)
            }

            Button {
                anchors.verticalCenter: parent.verticalCenter
                text: imgPath == "" ? i18n.tr("Add Image") : i18n.tr("Remove image")
//                text: "adada"
                visible: sendPage.mode == ""
//                iconSource: imgPath
                onClicked: {
                    if (imgPath == "") {
                        if (appData.isARM == 0) {
                            mainStack.push(Qt.resolvedUrl("./LocalPhotoPicker.qml"))
                            mainStack.currentPage.imgPicked.connect(setImgPath)
                        }
                        else {
                            mainView.addNotification(i18n.tr("This feature only support in desktop"), 3)
                        }
                    }
                    else {
                        imgPath = ""
                    }
                }
            }

            Image {
                id: imgPreview
                fillMode: Image.PreserveAspectFit
                source: imgPath
                sourceSize.height: parent.height
                visible: imgPath != ""
            }
        }

        ListItem.ValueSelector {
            id: selectorType
            text: i18n.tr("Options: ")
            values:  [""]
            visible: mode == "" ? false : true
            selectedIndex: 0

            onSelectedIndexChanged: {}
        }
    }

    //////////////////////////////////////////////////////////////////         Popup "@someone"
    Component {
        id: componentAtSheet

        ComposerSheet {
            id: sheetAt
            title: i18n.tr("@User")
            contentsHeight: parent.height

            function searchAtUser(kw) {
                function observer() {}
                observer.prototype = {
                    update: function(status, result)
                    {
                        if(status != "error"){
                            if(result.error) {
                                // TODO  error handler
                            }else {
                                // right result
//                                console.log("search at users: ", JSON.stringify(result))
                                modelAtUser.clear()
                                for (var i=0; i<result.length; i++) {
                                    modelAtUser.append(result[i])
                                }
                            }
                        }else{
                            // TODO  empty result
                        }
                    }
                }

                WB.searchAtUser(settings.getAccess_token(), kw, 20, 0, 2, new observer())
            }

            onCancelClicked: PopupUtils.close(sheetAt)
            onConfirmClicked: {
//                var atUserList = new Array
                for (var i=0; i<modelAtUser.count; i++) {
                    if (repeaterAtUser.itemAt(i).isChecked) {
//                        atUserList.push(modelAtUser.get(i))
                        textSendContent.text += " @" + modelAtUser.get(i).nickname + " "
                    }
                }

                PopupUtils.close(sheetAt)
            }

            Flickable {
                id: scrollArea
                boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
                anchors.fill: parent
                contentWidth: width
                contentHeight: innerAreaColumn.height/* + units.gu(2)*/

                Column {
                    id: innerAreaColumn

                    spacing: units.gu(1)
                    anchors {
                        top: parent.top;
                        //                topMargin: units.gu(1)
                        //                margins: units.gu(1)
                        left: parent.left; right: parent.right
                        //                leftMargin: units.gu(1); rightMargin: units.gu(1)
                    }
                    height: childrenRect.height

                    TextField {
                        id: tfSearch
                        anchors { left: parent.left; right: parent.right }
                        placeholderText: i18n.tr("Please input a keyword")

                        onTextChanged: {
                            sheetAt.searchAtUser(tfSearch.text)
                        }
                    }

                    Column {
                        id: colAtUser
                        anchors { left: parent.left; right: parent.right }

                        Repeater {
                            id: repeaterAtUser
                            model: ListModel { id: modelAtUser }
                            delegate: Component {
                                Item {
                                    anchors { left: parent.left; right: parent.right }
                                    height: childrenRect.height

                                    property alias isChecked: switchAtUser.checked

                                    Column {
                                        id: columnAtContent
                                        anchors {
                                            top: parent.top; topMargin: units.gu(0.5)
                                            left: parent.left; right: parent.right
//                                            leftMargin: units.gu(1); rightMargin: units.gu(1)
                                        }
                                        spacing: units.gu(0.5)
                                        height: childrenRect.height

                                        Item {
                                            anchors {
                                                left: parent.left; right: parent.right
                                                leftMargin: units.gu(1); rightMargin: units.gu(1)
                                            }
                                            height: switchAtUser.height

                                            Label {
                                                id: labelUserName
                                                anchors.verticalCenter: parent.verticalCenter
                                                color: "black"
                                                text: model.nickname
                                            }

                                            Switch {
                                                id: switchAtUser
                                                anchors { right: parent.right; rightMargin: units.gu(1) }
                                            }
                                        }

                                        ListItem.ThinDivider {
//                                            width: parent.width
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            switchAtUser.checked = !switchAtUser.checked
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }
    }// component
}
