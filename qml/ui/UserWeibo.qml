import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

Page {
    id: userWeibo
    //title: userName + qsTr("'s Weibo")

    property var uid
    property string userName: ""
    property int pageNum: 1

    Component.onCompleted:  {
        refresh();
    }

    function refresh() {
        modelWeibo.clear()

        pageNum = 1
//        isRefresh = true
        userStatus(Settings.getAccess_token(), pageNum)
    }

    function addMore() {
        pageNum++
        userStatus(Settings.getAccess_token(), pageNum)
    }

    //////////////////////////////////////////////////////////////////         user status
    function userStatus(token, page)
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
                        console.log("result.statuses.length: ", result.statuses.length)
                        for (var i=0; i<result.statuses.length; i++) {
                            modelWeibo.append( result.statuses[i] )
                        }
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.userGetWeibo(token, uid, page, new observer())
    }

    SilicaListView{
        id: lvUserWeibo
        anchors {
            fill: parent
            margins: Theme.paddingMedium
        }
        header: PageHeader {
            title: userName + qsTr("'s Weibo")
        }

        cacheBuffer: 999999/*height * 2*/
        //spacing: units.gu(1)
        model: modelWeibo
        footer: FooterLoadMore {
            onClicked: {userWeibo.addMore()}
        }

        delegate: delegateWeibo

    }

    Component {
        id: delegateWeibo

        DelegateWeibo {
            onUsWeiboClicked: {
                //                        console.log("weibo Detail:", JSON.stringify(modelWeibo.get(index)))
                toWeiboPage(modelWeibo, index)
            }
        }
    }

    ListModel {
        id: modelWeibo
    }
}
