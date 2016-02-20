import QtQuick 2.0
import Sailfish.Silica 1.0

SilicaFlickable {
    id: bottomPopupToolBar
    width: Screen.width
    height: column.height
    contentHeight: column.height
    enabled: opacity != 0

    property int menuSize: Theme.iconSizeMedium
    property bool popuped: false
    property bool enableToolbarMenu: true
    property bool showPaddingLine: false

    property alias popupContent: popupItem.children
    property alias toolBarContent: toolbar.children

    property real _progress: popuped ? 1.0 : 0.0

    readonly property int maxPopupHeight: Screen.height - Theme.itemSizeLarge - toolBarAreaHeight
    readonly property int toolBarAreaHeight: toolBarArea.height + column.spacing
//    default property alias content: toolbar.data

    signal popupReady

    function showPopup() {
        popuped = true;
    }
    function hidePopup() {
        popuped = false;
    }

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

        Rectangle {
            id: paddingLine
            width: parent.width
            height: showPaddingLine && bottomPopupToolBar.popuped ? 1 : 0
            color: Theme.highlightColor
            opacity: showPaddingLine && bottomPopupToolBar.popuped ? 1 : 0
        }

        Item {
            id: toolBarArea
            width: parent.width
            height: Math.max(toolbar.height, menu.height)
//            color: Theme.rgba(pullDownMenu.backgroundColor, Theme.highlightBackgroundOpacity)
            Rectangle {
                anchors.fill: parent
                z: parent.z -1
                color: Theme.highlightDimmerColor
                opacity: 0.5
            }
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
                enabled: enableToolbarMenu ? true : false
                visible: enableToolbarMenu ? true : false
                height: bottomPopupToolBar.menuSize
                width: enableToolbarMenu ? menu.height : 0
                icon.source: bottomPopupToolBar.popuped
                             ? "image://theme/icon-m-clear"
                             : "image://theme/icon-m-menu"
                onClicked: {
                    bottomPopupToolBar.popuped = !bottomPopupToolBar.popuped;
                }
            }
        }
    }
}

