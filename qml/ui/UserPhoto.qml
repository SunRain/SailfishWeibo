import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../components"

Page {
    id: userPhoto
    flickable: null

    property var uid
    property int pageNum: 1

    function refresh() {
//        modelWeibo.clear()

        pageNum = 1
        userGetPhoto(settings.getAccess_token(), pageNum)
    }

    function addMore() {
        pageNum++
        userGetPhoto(settings.getAccess_token(), pageNum)
    }

    //////////////////////////////////////////////////////////////////         user photo
    function userGetPhoto(token, page)
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
                        console.log("user photo: ", JSON.stringify(result))
//                        for (var i=0; i<result.statuses.length; i++) {
//                            modelWeibo.append( result.statuses[i] )
//                        }
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.userGetPhoto(token, uid, page, new observer())
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "black"
    }
}
