import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: notification
    width: parent ? parent.width : Screen.width
    height: label.height + Theme.paddingLarge * 2
    opacity: 0

    property alias text: label.text
    property int time: 3

    Component.onCompleted: {
        opacity = 1
        timerDisplay.start()
    }

    Behavior on opacity {
        FadeAnimation{}
    }
    Behavior on y {
        FadeAnimation{}
    }

    Timer {
        id: timerDisplay
        running: true;
        repeat: false;
        triggeredOnStart: false
        interval: time * 1000
        onTriggered: {
            animaDestroy.start()
        }
    }    
        
    Label {
        id: label
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: Theme.fontSizeMedium
        color: Theme.highlightColor
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
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
            NumberAnimation {
                target: notification
                property: "scale"
                to: 0.3
            }
            NumberAnimation {
                target: notification
                property: "x"
                to: notification.width * 2
            }
            NumberAnimation {
                target: notification
                property: "opacity"
                to: 0
            }
        }
        ScriptAction { script: notification.destroy() }
    }
}
