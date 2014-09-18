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

    Rectangle {
        id: usContainer
        border.color: Theme.highlightColor
        opacity: 0.3

        width: parent.width
        height: labelNotification.height + Theme.paddingMedium

        Label {
            id: labelNotification
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins:Theme.paddingSmall
            }
            font.pixelSize:Theme.fontSizeSmall

            color: Theme.highlightColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            text: notification.text
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
