import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../components"

Page {
    id: weiboMentionedPage
    title: i18n.tr("Weibo mentioned me")

    property var uid
    property string userName: ""
    property int pageNum: 1

    function refresh() {
        modelWeibo.clear()

        pageNum = 1
//        isRefresh = true
        weiboMentioned(settings.getAccess_token(), pageNum)
    }

    function addMore() {
        pageNum++
        weiboMentioned(settings.getAccess_token(), pageNum)
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

    ListView{
        id: lvUserWeibo
        anchors {
            fill: parent
            margins: units.gu(1)
        }
        cacheBuffer: 999999/*height * 2*/
        spacing: units.gu(1)
        model: modelWeibo
        footer: footerWeibo
        delegate: delegateWeibo

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
            width: lvUserWeibo.width
            height: units.gu(7)

            Label {
                anchors.centerIn: parent
                text: i18n.tr("click here to load more..")
            }

            MouseArea {
                anchors.fill: parent
                onClicked: userWeibo.addMore()
            }
        }
    }

    ListModel {
        id: modelWeibo
    }
}
