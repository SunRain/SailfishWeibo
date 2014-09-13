import QtQuick 2.0
//import Ubuntu.Components 0.1
import "../components"
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import Sailfish.Silica 1.0

/*Tab*/SilicaFlickable {
    id: weiboTab
    anchors.fill: parent
    //title: qsTr("Weibo")

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
        homeStatus(Settings.getAccess_token(), pageNum)
    }

    function addMore() {
        pageNum++
        homeStatus(Settings.getAccess_token(), pageNum)
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
                          console.log("status length: ", result.statuses.length)
                          console.log("status 0:", JSON.stringify(result.statuses[0]))
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
                    console.log("weiboTab === homeStatus error");
                }
            }
        }
        
        WB.weiboHomeStatus(token, page, new observer())
    }
    
    ListModel {
        id: modelWeibo
    }

    // Tell SilicaFlickable the height of its content.
    contentHeight: /*notificationBar.height+*/column.height
    
    Column{
        id: column
        
        width: mainView.width
        spacing: Theme.itemSizeMedium 
        Item{
            id:wrapper
            //color: "#3a5ac2"
            width: parent.width
            height: Screen.height
            SilicaListView{
                id: lvHomeWeibo
                anchors {
                    fill: parent
                    margins: Theme.paddingSmall
                }
                // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
                PullDownMenu {
                    MenuItem {
                        text: qsTr("Refresh")
                        onClicked: {
                            //pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
                            refresh();
                        }
                    }
                }
                
                cacheBuffer: 999999/*height * 2*/
                spacing: Theme.paddingMedium
                model: modelWeibo
                footer: footerWeibo
                delegate: delegateWeibo
                
                //            property real curY: 0
                //            onMovementStarted: { curY = contentY; console.log("onFlickingChanged: ", curY);  }
                
                //            onContentYChanged: {
                //                console.log("visibleArea.yPosition: ", visibleArea.yPosition)
                //            }
            }
        }
    }
    Component {
        id: delegateWeibo
        
        DelegateWeibo {
            onClicked: {
                console.log("weibo Detail:", JSON.stringify(modelWeibo.get(index)))
                //mainView.toWeiboPage(modelWeibo, index)
            }
        }
    }
    
    Component {
        id: footerWeibo
        
        Item {
            width: lvHomeWeibo.width
            height: Theme.fontSizeMedium + 4
            
            Label {
                anchors.centerIn: parent
                font.pixelSize: Theme.fontSizeMedium
                text: qsTr("click here to load more..")
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("WeiboTab === footerWeibo click")
                    weiboTab.addMore()
                }
            }
        }
    }
}
