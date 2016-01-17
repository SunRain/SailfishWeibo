import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: bottomPopupToolBar
    width: Screen.width
    height: column.height

    property int menuSize: Theme.iconSizeMedium
    property bool showPopup: false
    property bool popuped: showPopup

    property alias popupContent: popupItem.children

    property real _progress: showPopup ? 1.0 : 0.0

    readonly property int maxPopupHeight: Screen.height - Theme.itemSizeLarge - toolBarAreaHeight
    readonly property int toolBarAreaHeight: toolBarArea.height + column.spacing
    default property alias content: toolbar.data

    signal popupReady

    Behavior on _progress {
        SequentialAnimation{
            alwaysRunToEnd: true
            NumberAnimation {
                id: menuProgressAnimation
                duration: 300
                easing.type: Easing.InOutQuad
            }
            ScriptAction {
                script: {
                    if (popuped)
                        popupReady();
                }
            }
        }
    }
//    onPopupedChanged: {
//        if (popuped)
//            popupReady();
//    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingSmall
        Item {
            id: popupItemWrapper
            width: popupItem.width
            height: popupItem.height
            Rectangle {
                id: dimmerRect
                anchors.fill: parent
                color: Theme.highlightDimmerColor
                //z: popupItem.z - 1

                // The dimmed rectangle provides a seam between the background and foreground.  It shouldn't
                // pop in instantly but should be distinct for the majority of the animation so the animation
                // easing is cubic instead of the normal quad.
                opacity: bottomPopupToolBar.popuped ? 0.5 : 0.0
                Behavior on opacity {
                    NumberAnimation {
                        id: backgroundOpacityAnimation
                        duration: 300
                        easing.type: Easing.InOutCubic
                    }
                }
            }

            Item {
                id: popupItem
                clip: true
                width: bottomPopupToolBar.popuped ? Screen.width : 0
                height: bottomPopupToolBar.popuped
                        ? bottomPopupToolBar._progress * bottomPopupToolBar.maxPopupHeight
                        : 0
            }
        }

        Item {
            id: toolBarArea
            width: parent.width
            height: Math.max(toolbar.height, menu.height)
            Item {
                id: toolbar
                anchors {
                    top: parent.top
                    left: parent.left
                    right: menu.left
                    rightMargin: Theme.paddingSmall
                }
                clip: true
                implicitHeight: childrenRect.height
            }
            IconButton {
                id: menu
                anchors {
                    top: parent.top
                    right: parent.right
                    verticalCenter: toolBarArea.verticalCenter
                }
                height: bottomPopupToolBar.menuSize
                width: menu.height
                icon.source: bottomPopupToolBar.showPopup
                             ? "image://theme/icon-m-clear"
                             : "image://theme/icon-m-menu"
                onClicked: {
                    bottomPopupToolBar.showPopup = !bottomPopupToolBar.showPopup;
                }
            }
        }
    }
}

