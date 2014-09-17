import QtQuick 2.0
//import Ubuntu.Components 0.1
//import Ubuntu.Components.Popups 0.1
//import Ubuntu.Components.ListItems 0.1 as ListItem
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import Sailfish.Silica 1.0

import "../components"
import com.sunrain.sinaweibo 1.0

Page {
    id: sendPage
    //    title: qsTr("Send Weibo")
    //flickable: null
    
    property string mode: ""
//    property var repostType: [qsTr("No comments"), qsTr("Comment current Weibo"), qsTr("Comment original Weibo"), qsTr("Both")]
//    property var commentType: [qsTr("Do not comment original Weibo"), qsTr("Also comment original Weibo")]
    
    property string sendTitle
    property var info         // include id, cid, etc..
    property string imgPath: ""
    property int optionIndex: 0

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
                            //TODO  no Notification work atm
                            mainView.addNotification(qsTr("New Weibo sent"), 3)
                            pageStack.pop()
                        }
                    }
                }else{
                    // TODO  empty result
                    //TODO  no Notification work atm
                    mainView.addNotification(qsTr("Oops.. something wrong"), 3)
                }
            }
        }
        
        WB.weiboSendStatus(token, status, new observer())
    }
    
    NetworkHelper {
        id: networkHelper
    }
    
    // Connections for upload image
    Connections {
        id: connNetworkHelper
        target: networkHelper
        
        onUploadFinished: {
            var reply = JSON.parse(response)
            if (reply.error) {
                //TODO  no Notification work atm
                mainView.addNotification(qsTr("Oops.. something wrong"), 3)
            }
            else {
                if (reply.id != undefined) {
                    //TODO  no Notification work atm
                    mainView.addNotification(qsTr("New Weibo sent"), 3)
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
                            mainView.addNotification(qsTr("Repost sent"), 3)
                            pageStack.pop()
                        }
                    }
                }else{
                    // TODO  empty result
                    mainView.addNotification(qsTr("Oops.. something wrong"), 3)
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
                            mainView.addNotification(qsTr("Comment sent"), 3)
                            pageStack.pop()
                        }
                    }
                }else{
                    // TODO  empty result
                    mainView.addNotification(qsTr("Oops.. something wrong"), 3)
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
                            mainView.addNotification(qsTr("Reply sent"), 3)
                            pageStack.pop()
                        }
                    }
                }else{
                    // TODO  empty result
                    mainView.addNotification(qsTr("Oops.. something wrong"), 3)
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
    
    Component {
        id:atUserSheet
        AtUserComponent {
            id:atUserComponent
            anchors.fill: parent
            
            onUserClicked: {
                console.log("SendPage === We love " + userName);
                drawer.open = !drawer.open;
                parent.focus = true;
                
                content.text += " @" + userName + " "
            }
        }
    }

    Component {
        id:commentOption
        ComboBox {
            id: commentOptionComboBox
            width: parent.width
            label: qsTr("comment option")
            currentIndex: 0
            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Do not comment original Weibo")
                    onClicked: { optionIndex = 0; }
                }
                MenuItem {
                    text: qsTr("Also comment original Weibo")
                    onClicked: { optionIndex = 1;}
                }
            }
        }
    }

    Component {
        id: repostOption
        ComboBox {
            id: repostTypeComboBox
            width: parent.parent
            label: qsTr("repost option")
            currentIndex: 0
            menu: ContextMenu {
                MenuItem {
                    text: qsTr("No comments")
                    onClicked: { optionIndex = 0; }
                }
                MenuItem {
                    text: qsTr("Comment current Weibo")
                    onClicked: { optionIndex = 1; }
                }
                MenuItem {
                    text: qsTr("Comment original Weibo")
                    onClicked:  { optionIndex = 2; }
                }
                MenuItem {
                    text: qsTr("Both")
                    onClicked:  { optionIndex = 3; }
                }
            }
        }
    }
    
    /////////////////////////////// 主页面
    Drawer {
        id: drawer
        anchors.fill: parent
        dock: Dock.Bottom
        
        background: Loader {
            id:drawerBackgroundLoader
            anchors.fill: parent
            sourceComponent: atUserSheet
        }
        
        SilicaFlickable {
            anchors {
                fill: parent
                //leftMargin: page.isPortrait ? 0 : controlPanel.visibleSize
                //topMargin: page.isPortrait ? controlPanel.visibleSize : 0
                //rightMargin: page.isPortrait ? 0 : progressPanel.visibleSize
                //bottomMargin: page.isPortrait ? progressPanel.visibleSize : 0
            }
            
            PullDownMenu {
                MenuItem {
                    text: qsTr("Send")
                    onClicked: {
                        console.log("SendPage == SendIcon click, we send [" + content.text +"] " + optionIndex);

                        //TODO 是否添加图片在微博中
                        //noPic added in content
                        //sendStatus(Settings.getAccess_token(), content.text)
                        //pic addedin content
                        //mainView.addNotification(i18n.tr("Uploading, please wait.."), 2)
                        //var status = encodeURIComponent(textSendContent.text)
                        // networkHelper.uploadImgStatus(settings.getAccess_token(), status, imgPath)
                    }
                }
            }

            PushUpMenu {
                MenuItem {
                    text: qsTr("@SomeOne")
                    onClicked: {
                        drawer.open = !drawer.open;
                    }
                }
                MenuItem {
                    text: qsTr("Add Image")
                    //TODO 点击按钮后添加图片
                    onClicked: {
                        console.log("SendPage == here we want to add some images");
                    }
                }
            }

            contentHeight: column.height + Theme.paddingLarge
            
            VerticalScrollDecorator {}
            
            Column {
                id: column
                spacing: Theme.paddingLarge
                width: parent.width
                enabled: !drawer.opened

                PageHeader { title: sendTitle }
                
                TextArea {
                    id:content
                    width: parent.width
                    height: Math.max(parent.width/2, implicitHeight)
                    focus: true
                    horizontalAlignment: TextInput.AlignLeft
                    placeholderText: "Type multi-line text here"
                    label: "Expanding text area"
                    
                }

                Loader {
                    id: optionLoader
                    width: parent.width
                }
            }

            //添加输入框下部选型列表
            Component.onCompleted: {
                optionLoader.sourceComponent = optionLoader.Null;
                switch (mode) {
                case "repost" :
                    sendTitle = qsTr("Repost")
                    //selectorType.values = repostType
                    optionLoader.sourceComponent = repostOption;
                    break;
                case "comment" :
                    sendTitle = qsTr("Comment")
                    //selectorType.values = commentType
                    optionLoader.sourceComponent = commentOption;
                    break;
                case "reply" :
                    sendTitle = qsTr("Reply")
                    // selectorType.values = commentType
                    optionLoader.sourceComponent = commentOption;
                    break;
                default:
                    //sendPage.mode = ""
                    sendTitle = qsTr("Send Weibo")
                    // selectorType.values = [""]
                    break
                }
            }
        }
    }
}
    
    
    
    
    
    
    //////////////////////////////////////////////////////////////////         header
//    Rectangle {
//        id: recHeader
//        anchors { left: parent.left; right: parent.right }
//        height: btnCancel.height + 2//units.gu(2)
//        color: Qt.rgba(255, 255, 255, 0.2)

//        Label {
//            id: labelTitle
//            anchors.centerIn: parent
//            //fontSize: "large"
//            color: "black"
//            text: sendTitle
//        }

//        Button{
//            id: btnCancel
//            anchors {
//                left: parent.left; leftMargin: 1//units.gu(1)
//                verticalCenter: parent.verticalCenter
//            }
//            //gradient: UbuntuColors.greyGradient
//            text: qsTr("Cancel")

//            onClicked: {
//                pageStack.pop()
//            }
//        }

//        Button{
//            id: btnSend
//            anchors {
//                right: parent.right; rightMargin: 1//units.gu(1)
//                verticalCenter: parent.verticalCenter
//            }
//            text: qsTr("Send")

//            onClicked: {
//                switch (sendPage.mode) {
//                    //TODO 待完成后实现此功能
////                case "repost" :
////                    repostStatus(Settings.getAccess_token(), textSendContent.text, info.id, selectorType.selectedIndex)
////                    break
////                case "comment" :
////                    sendComment(Settings.getAccess_token(), textSendContent.text, info.id, selectorType.selectedIndex)
////                    break
////                case "reply" :
////                    replyComment(Settings.getAccess_token(), textSendContent.text, info.id, selectorType.selectedIndex, info.cid, 0)
////                    break
//                default:
//                    if (imgPath == "" || imgPath == undefined) {
//                        sendStatus(Settings.getAccess_token(), textSendContent.text)
//                    }
//                    else {
//                        mainView.addNotification(qsTr("Uploading, please wait.."), 2)
//                        var status = encodeURIComponent(textSendContent.text)
//                        networkHelper.uploadImgStatus(Settings.getAccess_token(), status, imgPath)
//                    }
//                    break
//                }
//            }
//        }
        
//        //TODO:暂时加在这里测试
//        Component.onCompleted: {
//            console.log("SendPage == header on onCompleted");
//            setMode(mode, info);
//        }
//    }


//    //////////////////////////////////////////////////////////////////         content
//    Column {
//        id: colContent
//        anchors {
////            fill: parent
//            top: recHeader.bottom;  topMargin: 1//units.gu(1)
//            left: parent.left; right: parent.right
//            leftMargin: /*units.gu(1)*/1; rightMargin: 1//units.gu(1)
//            bottomMargin: Qt.inputMethod.keyboardRectangle.height
//        }
//        spacing: /*units.gu(1)*/1
        
//        /*TextArea*/Label {
//            id: textSendContent
//            width: parent.width
//            height: 6//units.gu(16)
//        }

//        Row {
//            height:  6//units.gu(6)
//            spacing: 1//units.gu(1)

//            Button {
//                anchors.verticalCenter: parent.verticalCenter
//                text: "@Someone"
//                onClicked: {
//                    //TODO here we @someone
//                    console.log("here we want to @someone we love lol");
//                    //PopupUtils.open(componentAtSheet)
//                }
//            }

//            Button {
//                anchors.verticalCenter: parent.verticalCenter
//                text: imgPath == "" ? qsTr("Add Image") : qsTr("Remove image")
////                text: "adada"
//                visible: sendPage.mode == ""
////                iconSource: imgPath
//                onClicked: {
//                    if (imgPath == "") {
//                        if (appData.isARM == 0) {
//                            mainStack.push(Qt.resolvedUrl("./LocalPhotoPicker.qml"))
//                            mainStack.currentPage.imgPicked.connect(setImgPath)
//                        }
//                        else {
//                            mainView.addNotification(qsTr("This feature only support in desktop"), 3)
//                        }
//                    }
//                    else {
//                        imgPath = ""
//                    }
//                }
//            }

//            Image {
//                id: imgPreview
//                fillMode: Image.PreserveAspectFit
//                source: imgPath
//                sourceSize.height: parent.height
//                visible: imgPath != ""
//            }
//        }

        //TODO 需要使用Sailfish的控件来实现这个选项功能
//        ListItem.ValueSelector {
//            id: selectorType
//            text: qsTr("Options: ")
//            values:  [""]
//            visible: mode == "" ? false : true
//            selectedIndex: 0

//            onSelectedIndexChanged: {}
//        }
//    }

    //////////////////////////////////////////////////////////////////         Popup "@someone"
    //TODO @某人的功能，可以使用Sailfish的 Search或者Pop Panels实现
//    Component {
//        id: componentAtSheet

//        ComposerSheet {
//            id: sheetAt
//            title: qsTr("@User")
//            contentsHeight: parent.height

//            function searchAtUser(kw) {
//                function observer() {}
//                observer.prototype = {
//                    update: function(status, result)
//                    {
//                        if(status != "error"){
//                            if(result.error) {
//                                // TODO  error handler
//                            }else {
//                                // right result
////                                console.log("search at users: ", JSON.stringify(result))
//                                modelAtUser.clear()
//                                for (var i=0; i<result.length; i++) {
//                                    modelAtUser.append(result[i])
//                                }
//                            }
//                        }else{
//                            // TODO  empty result
//                        }
//                    }
//                }

//                WB.searchAtUser(Settings.getAccess_token(), kw, 20, 0, 2, new observer())
//            }

//            onCancelClicked: PopupUtils.close(sheetAt)
//            onConfirmClicked: {
////                var atUserList = new Array
//                for (var i=0; i<modelAtUser.count; i++) {
//                    if (repeaterAtUser.itemAt(i).isChecked) {
////                        atUserList.push(modelAtUser.get(i))
//                        textSendContent.text += " @" + modelAtUser.get(i).nickname + " "
//                    }
//                }

//                PopupUtils.close(sheetAt)
//            }

//            Flickable {
//                id: scrollArea
//                boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
//                anchors.fill: parent
//                contentWidth: width
//                contentHeight: innerAreaColumn.height/* + units.gu(2)*/

//                Column {
//                    id: innerAreaColumn

//                    spacing: units.gu(1)
//                    anchors {
//                        top: parent.top;
//                        //                topMargin: units.gu(1)
//                        //                margins: units.gu(1)
//                        left: parent.left; right: parent.right
//                        //                leftMargin: units.gu(1); rightMargin: units.gu(1)
//                    }
//                    height: childrenRect.height

//                    TextField {
//                        id: tfSearch
//                        anchors { left: parent.left; right: parent.right }
//                        placeholderText: qsTr("Please input a keyword")

//                        onTextChanged: {
//                            sheetAt.searchAtUser(tfSearch.text)
//                        }
//                    }

//                    Column {
//                        id: colAtUser
//                        anchors { left: parent.left; right: parent.right }

//                        Repeater {
//                            id: repeaterAtUser
//                            model: ListModel { id: modelAtUser }
//                            delegate: Component {
//                                Item {
//                                    anchors { left: parent.left; right: parent.right }
//                                    height: childrenRect.height

//                                    property alias isChecked: switchAtUser.checked

//                                    Column {
//                                        id: columnAtContent
//                                        anchors {
//                                            top: parent.top; topMargin: units.gu(0.5)
//                                            left: parent.left; right: parent.right
////                                            leftMargin: units.gu(1); rightMargin: units.gu(1)
//                                        }
//                                        spacing: units.gu(0.5)
//                                        height: childrenRect.height

//                                        Item {
//                                            anchors {
//                                                left: parent.left; right: parent.right
//                                                leftMargin: units.gu(1); rightMargin: units.gu(1)
//                                            }
//                                            height: switchAtUser.height

//                                            Label {
//                                                id: labelUserName
//                                                anchors.verticalCenter: parent.verticalCenter
//                                                color: "black"
//                                                text: model.nickname
//                                            }

//                                            Switch {
//                                                id: switchAtUser
//                                                anchors { right: parent.right; rightMargin: units.gu(1) }
//                                            }
//                                        }

////                                        ListItem.ThinDivider {
//////                                            width: parent.width
////                                        }
//                                    }

//                                    MouseArea {
//                                        anchors.fill: parent
//                                        onClicked: {
//                                            switchAtUser.checked = !switchAtUser.checked
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }

//        }
//    }// component
//}
