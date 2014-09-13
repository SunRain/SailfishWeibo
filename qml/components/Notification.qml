import QtQuick 2.0
//import Ubuntu.Components 0.1
import Sailfish.Silica 1.0

Item {
    id: notification
    anchors { left: parent.left; right: parent.right }
    height: usContainer.height
    opacity: 0

    property string text: ""
    property int time: 3

    Component.onCompleted: {
        console.log("notification ===  onCompleted");
        opacity = 1
        timerDisplay.start()
    }

    Behavior on opacity { NumberAnimation{} }

    Timer {
        id: timerDisplay
        running: true; repeat: false; triggeredOnStart: false
        interval: time * 1000

        onTriggered: {
            animaDestroy.start()
        }
    }

    /*UbuntuShape*/ Rectangle{
        id: usContainer
//        gradientColor: "#000080"
        color: "#000080"
        radius: "medium"

//        anchors {
//            left: parent.left; right: parent.right
//        }
        width: parent.width
        height: labelNotification.paintedHeight + units.gu(2)

        Label {
            id: labelNotification
            text: notification.text
//            fontSize: "large"
            color: "white"
//            elide: Text.ElideRight
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            anchors {
                top: parent.top; topMargin: units.gu(1)
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width - units.gu(2)
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: animaDestroy.start()
    }

    // Fade out the text in prepartion for removal
    SequentialAnimation {
        id: animaDestroy
        running: false

        ParallelAnimation {
//            running: animaDestroy.running

            /*UbuntuNumberAnimation*/ NumberAnimation {
                target: notification
                property: "scale"
                to: 0.3
            }
            /*UbuntuNumberAnimation*/ NumberAnimation {
                target: usContainer
                property: "x"
                to: usContainer.width * 2
            }
            /*UbuntuNumberAnimation*/NumberAnimation {
                target: notification
                property: "opacity"
                to: 0
            }
        }

        ScriptAction { script: notification.destroy() }
    }
}
