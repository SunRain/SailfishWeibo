import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

Page {
    id: gallery
    anchors.fill: parent

    property alias modelGallery: imageListview.model
    property var index

    //property alias _menuOpen: drawer.opened

    //backNavigation: drawer.open

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

    //////////////////////////////////////////////      a listview to show the images of one weibo
    SilicaListView {
        id: imageListview

        anchors{
            top:parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Theme.paddingSmall
        }
        
        snapMode: ListView.SnapOneItem
        orientation: ListView.HorizontalFlick
        model: modelGallery
        delegate: delageteImage
        clip: true
        cacheBuffer: width
        highlightRangeMode: ListView.StrictlyEnforceRange
    }

    Component {
        id: delageteImage

        Item {
            id: flickContainer
            width: imageListview.width
            height: imageListview.height
            clip: true

            property bool _runningBusyIndicator: true

            BusyIndicator {
                id:busyIndicator
                running: _runningBusyIndicator
                size: BusyIndicatorSize.Large
                anchors.centerIn: parent
                enabled: _runningBusyIndicator
            }

            Loader {
                anchors.fill: parent
                sourceComponent: _isGifImage(model.thumbnail_pic) ? animatedImageComponent : imageComponent
            }

            ////////////////////// for gif image
            Component {
                id:animatedImageComponent
                AnimatedImage {
                    id:animatedImageWeibo
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit

                    //asynchronous for LOCAL filesystem, http are always loaded asynchonously.
                    //anyway, we set this
                    asynchronous: true

                    source: _toLarge(model.thumbnail_pic)
                    onStatusChanged: {
                        if (animatedImageWeibo.status == AnimatedImage.Ready) {
                            _runningBusyIndicator = false;
                        }
                    }
                }
            }
            /////////////////////// other image
            Component {
                id: imageComponent
                Flickable {
                    anchors.centerIn: parent
                    width: imageweibo.width > Screen.width ? Screen.width : imageweibo.width
                    height: imageweibo.height> Screen.height? Screen.height : imageweibo.height

                    contentWidth: imageweibo.width
                    contentHeight: imageweibo.height

                    ImageViewer {
                        id: imageweibo
                        //anchors.fill: parent
                        //anchors.centerIn: parent
                        maximumWidth: Screen.width//parent.width
                        maximumHeight: Screen.height //parent.height
                        enableZoom: true
                        //menuOpen: gallery._menuOpen
                        source: tokenProvider.useHackLogin
                                ? _toHackLarge(model.url, model.size)
                                :_toLarge(model.thumbnail_pic )
                        onClicked: {}
                        onLoadReady: {_runningBusyIndicator = false;}
                    }
                }
            } // Component
        } //Item
    } //Component
}
