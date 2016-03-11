import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page {
    id: gallery

    property alias modelGallery : imageListview.model
    property var index
    property int _indicatorIndex: 0

    showNavigationIndicator: false

    Component.onCompleted: {
        _setNewIndex(index);
    }

    function _setNewIndex(imageIndex) {
        imageListview.currentIndex = imageIndex
        imageListview.positionViewAtIndex(imageListview.currentIndex, ListView.Center)
    }

    function _toHackLarge(url, patten) {
        var tmp = url + ""
        tmp = tmp.replace(patten, "large")
        return tmp
    }

    function _toLarge(url) {
        var tmp = url + ""
        tmp = tmp.replace("thumbnail", "large")
        return tmp
    }
    
    function _isGifImage(url) {
        var tmp = url + "";
        if (tmp.substr(-4,4) == ".gif") {
            return true;
        }
        return false;
    }

    SilicaListView {
        id: imageListview
        anchors.fill: parent
        snapMode: ListView.SnapOneItem
        orientation: ListView.HorizontalFlick
        model: modelGallery
        clip: true
        cacheBuffer: 0
        highlightRangeMode: ListView.StrictlyEnforceRange
        delegate: ImageViewer {
            id: imageweibo
            property var _busyIndicator
            property bool _runningBusyIndicator: true
            width: ListView.view.width
            height: ListView.view.height
            source: tokenProvider.useHackLogin
                    ? _toHackLarge(model.url, model.size)
                    : _toLarge(model.thumbnail_pic)
            onLoadingStatus: {
                if (status == Image.Ready) {
                    _runningBusyIndicator = false;
                }
            }
            BusyIndicator {
                size: BusyIndicatorSize.Medium
                anchors.centerIn: parent
                running: imageweibo._runningBusyIndicator
                z: parent.z + 10
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageStack.pop();
                }
            }
        }
    }
}
