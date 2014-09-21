import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

Page {
    id: weiboMentionedPage
    //title: qsTr("Weibo mentioned me")

    property var uid
    property string userName: ""
    property int pageNum: 1

    function refresh() {
        modelWeibo.clear()

        pageNum = 1
//        isRefresh = true
        weiboMentioned(Settings.getAccess_token(), pageNum)
    }

    function addMore() {
        pageNum++
        weiboMentioned(Settings.getAccess_token(), pageNum)
    }

    //////////////////////////////////////////////////////////////////         user status mentioned me
    function weiboMentioned(token, page)
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
//                        console.log("weibo mentioned: ", JSON.stringify(result))
                        for (var i=0; i<result.statuses.length; i++) {
                            modelWeibo.append( result.statuses[i] )
                        }
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.messageGetWeiboMentioned(token, page, new observer())
    }

    Component.onCompleted: {
        weiboMentionedPage.refresh();
    }

    ListView{
        id: lvUserWeibo
        anchors {
            fill: parent
            //margins: units.gu(1)
        }
        cacheBuffer: 999999/*height * 2*/
        //spacing: units.gu(1)
        model: modelWeibo
        footer: /*footerWeibo*/FooterLoadMore {
            onClicked: { weiboMentionedPage.addMore();}
        }
        delegate: delegateWeibo
        header:PageHeader {
            id:pageHeader
            title: qsTr("Weibo mentioned me")
        }

    }

    Component {
        id: delegateWeibo

        DelegateWeibo {
            onClicked: {
                //                        console.log("weibo Detail:", JSON.stringify(modelWeibo.get(index)))
                //toWeiboPage(modelWeibo, index)
                pageStack.push(Qt.resolvedUrl("WeiboPage.qml"),
                                {"weiboModel":modelWeibo,
                                   "newIndex":index})
            }
        }
    }

//    Component {
//        id: footerWeibo

//        Item {
//            width: lvUserWeibo.width
//            height: Theme.itemSizeMedium

//            Button {
//                anchors.centerIn: parent
//                text: qsTr("click here to load more..")
//                onClicked: {
//                    weiboMentionedPage.addMore();
//                }
//            }
//        }
//    }

    ListModel {
        id: modelWeibo
    }
}
