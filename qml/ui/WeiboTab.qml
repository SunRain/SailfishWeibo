import QtQuick 2.0
import Ubuntu.Components 0.1
import "../components"
import "../js/weiboapi.js" as WB

Tab {
    id: weiboTab
    anchors.fill: parent
    title: i18n.tr("Weibo")

    property int pageNum: 1
    property bool isRefresh: false

    signal sendNewWeibo

    function refresh() {
        // TODO refresh all weibo
        modelWeibo.clear()
//        for (var i=0; i<result.statuses.length; i++) {
//            modelWeibo.append( result.statuses[i] )
//        }
        pageNum = 1
        isRefresh = true
        homeStatus(settings.getAccess_token(), pageNum)
    }

    function addMore() {
        pageNum++
        homeStatus(settings.getAccess_token(), pageNum)
    }

    //////////////////////////////////////////////////////////////////         home status
    function homeStatus(token, page)
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
//                        console.log("status length: ", result.statuses.length)
//                        console.log("status 0:", JSON.stringify(result.statuses[0]))
//                        if (page == 1) mainView.refreshHome(result)
                        if (isRefresh) {
                            isRefresh = false
                        }
                        for (var i=0; i<result.statuses.length; i++) {
                            modelWeibo.append( result.statuses[i] )
                        }
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.weiboHomeStatus(token, page, new observer())
    }

    ListModel {
        id: modelWeibo
    }

    page: Page {
        id: pageHome
//        flickable: null     // uncomment this line can make scrolling more smooth

        tools: ToolbarItems {
            id: toolbarWeibo

            back: ToolbarButton {
                action: Action {
                    text:  i18n.tr("Refresh")
                    iconSource: Qt.resolvedUrl("../graphics/reload.svg")
                    onTriggered:
                    {
                        // TODO: refresh
                        refresh()
                    }
                }
            }

            ToolbarButton {
                action: Action {
                    text:  i18n.tr("New")
                    iconSource: Qt.resolvedUrl("../graphics/edit.svg")
                    onTriggered: {
                        // TODO: send weibo
                        sendNewWeibo()
                    } // onTriggered
                }
            }
        }

        ListView{
            id: lvHomeWeibo
            anchors {
                fill: parent
                margins: units.gu(1)
            }
            cacheBuffer: 999999/*height * 2*/
            spacing: units.gu(1)
            model: modelWeibo
            footer: footerWeibo
            delegate: delegateWeibo

//            property real curY: 0
//            onMovementStarted: { curY = contentY; console.log("onFlickingChanged: ", curY);  }

//            onContentYChanged: {
//                console.log("visibleArea.yPosition: ", visibleArea.yPosition)
//            }
        }

        Component {
            id: delegateWeibo

            DelegateWeibo {
                onClicked: {
                    //                        console.log("weibo Detail:", JSON.stringify(modelWeibo.get(index)))
                    mainView.toWeiboPage(modelWeibo, index)
                }
            }
        }

        Component {
            id: footerWeibo

            Item {
                width: lvHomeWeibo.width
                height: units.gu(7)

                Label {
                    anchors.centerIn: parent
                    text: i18n.tr("click here to load more..")
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: weiboTab.addMore()
                }
            }
        }

    }
}
