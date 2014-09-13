import QtQuick 2.0
//import QtQuick.XmlListModel 2.0
//import Ubuntu.Components 0.1
//import Ubuntu.Components.ListItems 0.1 as ListItem
//import Ubuntu.Components.Popups 0.1
import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../components"

Page {
    objectName: "weibofeedpage"
    id: weiboPage
    title: i18n.tr("Weibo Content")
    flickable: null

    signal articleStatusChanged(int tagId, int articleId, string status)
    signal articleFavouriteChanged(var article, string favourite)
//    signal commentsWanted(var weiboId, int modelIndex)

    property string weiboModelUrl: ""
    property string weiboTitle: ""
    property var weiboModel
    property var weiboItem: null
    property bool preventIndexChangeHandler: false

    property var commentInfo

    function setNewIndex(weiboIndex) {
        weiboListview.currentIndex = weiboIndex
        weiboListview.positionViewAtIndex(weiboListview.currentIndex, ListView.Center)
    }

    function setFeed(model, index) {
        /* Setting new model and not-null index will cause two change events instead of one.
         * Settings "preventIndexChangeHandler" to true helps to avoid it.
         */
        if (weiboModel != model && index !== 0)
            preventIndexChangeHandler = true
        weiboModel = model
        setNewIndex(index)
    }

    function reloadPageContent() {

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
                    console.log("comment info: ", JSON.stringify(weiboPage.commentInfo))
                    PopupUtils.close(dialogue)
                    mainView.toSendPage("reply", weiboPage.commentInfo)
                }
            }
            Button {
                text: i18n.tr("Copy")
//                onClicked: PopupUtils.close(dialogue)
            }
            Button{
                gradient: UbuntuColors.greyGradient
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }


//    tools: ToolbarItems {
//        objectName: "pageBackBtn"
//        id: toolbar

//        ToolbarButton {
//            id: readingOptionsButton
//            /* QtRoS - Set visibility to true in line below to see options popup.
//             * There are no guides on dark and light theme yet, as on font size.
//             * So it is just logic for storing settings without any visual effects.
//             */
//            visible: false
//            action: Action {
//                text:  i18n.tr("Options")
//                iconSource: Qt.resolvedUrl("./icons_tmp/settings.svg")
//                onTriggered:
//                {
//                    PopupUtils.open(readingOptionsPopoverComponent, readingOptionsButton)
//                }
//            }
//        }

//        ToolbarButton {
//            action: Action {
//                text:  weiboItem == null ? "" : (weiboItem.favourite == "0" ? i18n.tr("Save") : i18n.tr("Remove"))
//                iconSource: {
//                    if (weiboItem == null || weiboItem.favourite == "0")
//                        return Qt.resolvedUrl("./icons_tmp/favorite-unselected.svg")
//                    else return Qt.resolvedUrl("./icons_tmp/favorite-selected.svg")
//                }
//                onTriggered: {
//                    var fav = (weiboItem.favourite == "0" ? "1" : "0")
//                    var dbResult = DB.updateArticleFavourite(weiboItem.id, fav)
//                    if (dbResult.rowsAffected == 1) {
//                        //weiboItem.favourite = fav
//                        var dbResult1 = DB.updateArticleStatus(weiboItem.id, "0")
//                        if (dbResult1.rowsAffected == 1) {
//                            // comment bellow to disable status signal, all articles will be set as read
//                            //articleStatusChanged(weiboItem.tagId, weiboItem.id, "0" /*weiboItem.status*/ )
//                        }

//                        articleFavouriteChanged(weiboItem, fav)
//                    }
//                }
//            }
//        }

//        ToolbarButton {
//            action: Action {
//                text:  i18n.tr("Open site")
//                iconSource: Qt.resolvedUrl("./icons_tmp/go-to.svg")
//                onTriggered:
//                {
//                    console.log("Open site", weiboListview.model.get(weiboListview.currentIndex).link)
//                    Qt.openUrlExternally(weiboListview.model.get(weiboListview.currentIndex).link)
//                }
//            }
//        }
//    }

/*    Component {
        id: readingOptionsPopoverComponent

        Popover {
            id: readingOptionsPopover

            Component.onCompleted: {
//                var useDarkTheme = DB.getUseDarkTheme()
//                console.log("USE DARK", useDarkTheme)
                fontSizeSlider.value = optionsKeeper.fontSize()
                buttonRow.updateButtonsState()
            }

            Column {
                id: contentColumn

                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                }

                ListItem.Empty {
                    Row {
                        id: buttonRow

                        property bool useDark: false
                        spacing: units.gu(2)
                        anchors.centerIn: parent
                        Button {
                            text: "Dark"
                            width: units.gu(14)
                            gradient: buttonRow.useDark ? UbuntuColors.orangeGradient : UbuntuColors.greyGradient
                            onClicked: {
                                optionsKeeper.setUseDarkTheme(true)
                                buttonRow.updateButtonsState()
                            }
                        }

                        Button {
                            text: "Light"
                            width: units.gu(14)
                            gradient: buttonRow.useDark ? UbuntuColors.greyGradient : UbuntuColors.orangeGradient
                            onClicked: {
                                optionsKeeper.setUseDarkTheme(false)
                                buttonRow.updateButtonsState()
                            }
                        }

                        function updateButtonsState() {
                            useDark = optionsKeeper.useDarkTheme()
                        }
                    }
                }

                ListItem.Empty {
                    showDivider: false
                    Label {
                        id: lblLess

                        text: "A"
                        fontSize: "small"
                        color: "black" // TODO TEMP
                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    Slider {
                        id: fontSizeSlider

                        anchors {
                            right: lblMore.left
                            rightMargin: units.gu(1)
                            left: lblLess.right
                            leftMargin: units.gu(1)
                            verticalCenter: parent.verticalCenter
                        }

                        minimumValue: 0
                        maximumValue: 2

                        onValueChanged: {
                            var res
                            if (value < maximumValue / 3)
                                res = 0
                            else if (value < maximumValue / 3 * 2)
                                res = 1
                            else res = 2

                            optionsKeeper.setFontSize(res)
                        }

                        function formatValue(v) {
                            if (v < maximumValue / 3)
                                return i18n.tr("Small")
                            else if (v < maximumValue / 3 * 2)
                                return i18n.tr("Mid")
                            else return i18n.tr("Large")
                        }
                    } // SLider

                    Label {
                        id: lblMore

                        text: "A"
                        fontSize: "large"
                        color: "black" // TODO TEMP
                        anchors {
                            right: parent.right
                            rightMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }
                    }
                } // ListItem.Empty
            }
        }
    }*/ // Component

    //////////////////////////////////////////////      a listview to show the weibo content
    ListView {
        id: weiboListview

        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: units.gu(2)
        anchors.top: parent.top
        anchors.topMargin: units.gu(2)
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds
        orientation: ListView.Horizontal
        contentHeight: parent.width * count
        model: weiboModel
        delegate: xmlDelegate
        clip: true
        highlightFollowsCurrentItem: true
        highlightRangeMode: ListView.StrictlyEnforceRange

        onCurrentIndexChanged: {
            console.log("ListView onCurrentIndexChanged", currentIndex, preventIndexChangeHandler)
            if (preventIndexChangeHandler) {
                preventIndexChangeHandler = false
                return
            }

            if (weiboModel.count == 0) // It is normal bevaviour.
                return

            if (weiboModel == null || weiboModel.get == undefined) {
                console.log("---- Stange behavior ----")
                console.trace()
                return
            }

            weiboItem = weiboModel.get(currentIndex)
            currentItem.getComments(settings.getAccess_token(), weiboItem.id, 1)
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
    }

    //////////////////////////////////////////////      delegate for ListView
    Component {
        id: xmlDelegate

        Flickable {
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
//                                console.log("comments : ", JSON.stringify(result))
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

                spacing: units.gu(2)
                anchors {
                    left: parent.left; right: parent.right
                    leftMargin: units.gu(1); rightMargin: units.gu(1)
                }

                DelegateWeibo {
                    onClicked: {
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

                Rectangle {
                    width: parent.width
                    height: childrenRect.height
                    color: Qt.rgba(255, 255, 255, 0.2)

                    ListView {
                        width: parent.width
                        height: contentItem.childrenRect.height
                        interactive: false
                        clip: true
                        spacing: units.gu(1)
                        model: ListModel { id: modelComment }
                        delegate: delegateComment
                    }
                }

                Component {
                    id: delegateComment

                    Item {
                        width: parent.width
                        height: childrenRect.height

                        Column {
                            id: columnWContent
                            anchors {
                                top: parent.top; topMargin: units.gu(1)
                                left: parent.left; right: parent.right
                                leftMargin: units.gu(1); rightMargin: units.gu(1)
                            }
                            spacing: units.gu(0.5)
                            height: childrenRect.height

                            Row {
                                id: rowUser
                                anchors { left: parent.left; right: parent.right }
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
                                id: labelWeibo
                                width: parent.width
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                color: "black"
                                text: model.text
                            }

                            ListItem.ThinDivider {
                                width: parent.width
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                weiboPage.commentInfo = { "id": weiboModel.get(weiboIndex).id, "cid": model.id}
                                PopupUtils.open(dialog)
                            }
                        }
                    }
                }

//                Row {
//                    width: parent.width - units.gu(4)
//                    height: labelTime.paintedHeight
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    spacing: units.gu(1)

//                    Image {
//                        id: imgFavourite
//                        anchors.verticalCenter: labelTime.verticalCenter
//                        fillMode: Image.PreserveAspectCrop
//                        source: Qt.resolvedUrl("./icons_tmp/favorite-selected.svg")
//                        sourceSize.height: weiboItem == null ? 0 : (weiboItem.favourite == "1" ? units.gu(2) : 0)
//                        visible: weiboItem == null ? false : (weiboItem.favourite == "1")
//                        smooth: true
//                    }

//                    Label {
//                        id: labelTime
//                        text: DateUtils.formatRelativeTime(i18n, pubdate)
//                        fontSize: "small"
//                        width: parent.width - units.gu(3)
//                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
//                    }
//                }
//                Label {
//                    id: label_time
//                    text: DateUtils.formatRelativeTime(i18n, pubdate)
//                    fontSize: "small"
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    width: parent.width - units.gu(4)
//                }

//                Label {
//                    fontSize: "large"
//                    text: title
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    width: parent.width - units.gu(4)
//                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
//                }

//                Label {
//                    text: content
//                    linkColor: "white"
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    width: parent.width - units.gu(4)
//                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
//                    clip: true

//                    onLinkActivated: Qt.openUrlExternally(link)
//                }

//                Label {
//                    id: label_feedname
//                    text: weiboTitle
//                    fontSize: "small"
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    width: parent.width - units.gu(4)
//                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
//                }




            }
        } // Flickable
    } // Component

}
