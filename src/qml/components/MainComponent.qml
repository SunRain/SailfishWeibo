import QtQuick 2.0
import Sailfish.Silica 1.0

Component{
    id:mainComponent
    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent
        
        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Show Page 2")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))	            
            }
        }
        
        // Tell SilicaFlickable the height of its content.
        contentHeight: notificationBar.height+column.height
        
        //FIXME:这个column是起什么作用？
        Column {
            id: notificationBar
            anchors {
                fill: parent
                topMargin: 10//units.gu(10)
                leftMargin: parent.width / 2
                rightMargin: 2//units.gu(2)
                bottomMargin: 2//units.gu(2)
            }
            z: 9999
            spacing: 1//units.gu(1)
            
            move: Transition { /*UbuntuNumberAnimation*/NumberAnimation { properties: "y" } }
        }
        
        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column
            
            width: mainView.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("UI Template")
            }
            Label { 
                x: Theme.paddingLarge
                text: qsTr("Hello Sailors")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
        }
        
        Component.onCompleted: {
            console.log("mainComponent onCompleted");
           // addNotification(qsTr("Welcome"), 3);
        }
    }
    
    // pls use this function to add notification: mainView.addNotification(string, int)
    function addNotification(inText, inTime) {
        var text = inText == undefined ? "" : inText
        var time = inTime == undefined ? 3 : inTime
        var noti = Qt.createComponent("../components/Notification.qml")
        var notiItem = noti.createObject(notificationBar, { "text": text, "time": time })
    }
    
}
