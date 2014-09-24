import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../components"

Tab {
    id: settingTab
    title: i18n.tr("Setting")

    function logOut()
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
                        if (result.result == "true") {
                            settings.setAccess_token("")
                            mainView.reset()
                        }
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.weiboLogOut(settings.getAccess_token(), new observer())
    }

    page: Page {
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
                    margins: units.gu(1)
                    left: parent.left; right: parent.right
                    //                leftMargin: units.gu(1); rightMargin: units.gu(1)
                }
                height: childrenRect.height

                UbuntuShape {
                    anchors {
                        left: parent.left; right: parent.right
                    }
                    height: units.gu(6)
                    radius: "medium"
                    color: Qt.rgba(255 ,255 ,255 ,0.3)

                    Label {
                        anchors.centerIn: parent
                        fontSize: "large"
                        text: i18n.tr("About <b><i>AesyWeibo</i></b>")
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
//                            mainStack.push(Qt.resolvedUrl("./AboutPage.qml"))
                            PopupUtils.open(dialog)
                        }
                    }
                }

                Button {
                    anchors {
                        left: parent.left; right: parent.right
                    }
                    text: i18n.tr("Log out")
                    onClicked: logOut()
                }
            }
        }
    }

    Component {
        id: dialog
        AboutPage{}
    }
}
