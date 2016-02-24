import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: optionItem
    property variant menu
    property Item _menuItem
    property bool menuOpen: _menuItem != null && _menuItem._open
    property real arrowSize: Theme.iconSizeSmallPlus
    property string openActionIcon: appUtility.pathTo("qml/graphics/action_open.png")
    property string closeActionIcon: appUtility.pathTo("qml/graphics/action_collapse.png")

    default property alias children: subcontent.data

//    property bool showMenuOnPressAndHold: true

    // If this item is removed by a RemorseItem, do not restore visibility
    // This binding should be removed when JB#8682 is addressed
    property bool __silica_item_removed
    
    signal menuStateChanged(bool opened)
//    signal clicked
    
    Binding on opacity {
        when: __silica_item_removed
        value: 0.0
    }

    onMenuOpenChanged: {
        if (ListView.view && ('__silica_contextmenu_instance' in ListView.view)) {
            ListView.view.__silica_contextmenu_instance = menuOpen ? _menuItem : null
        }
        menuStateChanged(menuOpen);
    }

    function remorseAction(text, action, timeout) {
        // null parent because a reference is held by RemorseItem until
        // it either triggers or is cancelled.
        var remorse = remorseComponent.createObject(null)
        remorse.execute(contentItem, text, action, timeout)
    }

    function animateRemoval(delegate) {
        if (delegate === undefined) {
            delegate = optionItem
        }
        removeComponent.createObject(delegate, { "target": delegate })
    }

    function showMenu(properties) {
        if (menu == null) {
            return null
        }
        if (_menuItem == null) {
            if (menu.createObject !== undefined) {
                _menuItem = menu.createObject(optionItem, properties || {})
                _menuItem.closed.connect(function() { _menuItem.destroy() })
            } else {
                _menuItem = menu
            }
            //FIXME dirty hack for contexmenu display
//            _menuItem.z = optionItem.z + 1;
            _menuItem.x = -(Screen.width - optionItem.width)/2
        }
        if (_menuItem) {
            if (menu.createObject === undefined) {
                for (var prop in properties) {
                    if (prop in _menuItem) {
                        _menuItem[prop] = properties[prop];
                    }
                }
            }
            _menuItem.show(optionItem)
        }
        return _menuItem
    }

    function hideMenu() {
        if (_menuItem != null) {
            _menuItem.hide()
        }
    }

    highlighted: down || menuOpen
    height: menuOpen ? _menuItem.height + contentItem.height : contentItem.height
    contentHeight: Theme.itemSizeSmall
    _backgroundColor: Theme.rgba(Theme.highlightBackgroundColor, _showPress && !menuOpen ? Theme.highlightBackgroundOpacity : 0)

//    onClicked: {
//        optionItem.clicked();
//    }

    Item {
        anchors.fill: parent
        Item {
            id: subcontent
            anchors {
                left: parent.left
                top: parent.top
                right: arrow.left
            }
            height: parent.height
        }
        MouseArea {
            id: arrow
            height: parent.height
            width: Math.min(parent.height, Theme.itemSizeMedium)
            anchors {
                right: parent.right
                top: parent.top
            }
            enabled: menu != null
            visible: menu != null
            Image {
                anchors.centerIn: parent
                width: Math.min(optionItem.arrowSize, arrow.width, arrow.height)
                height: width
                fillMode: Image.PreserveAspectFit
                source: menuOpen ? optionItem.closeActionIcon : optionItem.openActionIcon
            }
            onClicked: {
                showMenu();
            }
        }
    }

    Component {
        id: remorseComponent
        RemorseItem { }
    }

    Component {
        id: removeComponent
        RemoveAnimation {
            running: true
        }
    }

    Component.onDestruction: {
        if (_menuItem != null) {
            _menuItem.hide()
            _menuItem._parentDestroyed()
        }

        // This item must not be removed if reused in an ItemPool
        __silica_item_removed = false
    }
}
