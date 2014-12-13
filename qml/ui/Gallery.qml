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
        setNewIndex(index);
    }

    function setNewIndex(imageIndex) {
        console.log("=========== setNewIndex " + imageIndex);

        imageListview.currentIndex = imageIndex
        imageListview.positionViewAtIndex(imageListview.currentIndex, ListView.Center)
    }

    function toLarge(url) {
        var tmp = url + ""
        tmp = tmp.replace("thumbnail", "large")

        console.log("=========== toLarge " + tmp);

        return tmp
    }
    
    function isGifImage(url) {
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

//        Drawer {
//            id:drawer
//            dock:Dock.Top
//            hideOnMinimize: true
//            anchors.fill: parent
//            open: true

//            background: Label {
//                text: "label text  "
//            }

            Item {
                id: flickContainer
                width: imageListview.width
                height: imageListview.height
                clip: true

                property bool runningBusyIndicator: false //true

                BusyIndicator {
                    id:busyIndicator
                    running: runningBusyIndicator
                    size: BusyIndicatorSize.Large
                    anchors.centerIn: parent
                    enabled: runningBusyIndicator
                }

                Loader {
                    anchors.fill: parent
                    sourceComponent: isGifImage(model.thumbnail_pic) ? animatedImageComponent : imageComponent
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

                        source: {
                            toLarge(model.thumbnail_pic)
                        }
                        onStatusChanged: {
                            if (animatedImageWeibo.status == AnimatedImage.Ready) {
                                runningBusyIndicator = false;
                            }
                        }
                    }
                }
                Component {
                    id: imageComponent
                    ImageViewer {
                        anchors.fill: parent
                        menuOpen: false//gallery._menuOpen
                        source: {
                            toLarge(model.thumbnail_pic)
                        }
                        onClicked: {
                            drawer.open = !drawer.opened
                        }

                    }
                }

                /////////////////////// other image
                //            Component {
                //                id:imageComponent
                
                //                Flickable {
                //                    anchors.centerIn: parent

                //                    width: imageweibo.width > Screen.width ? Screen.width : imageweibo.width
                //                    height: imageweibo.height> Screen.height? Screen.height : imageweibo.height

                //                    contentWidth: imageweibo.width
                //                    contentHeight: imageweibo.height

                //                    Image {
                //                        id: imageweibo

                //                        fillMode: Image.PreserveAspectFit
                //                        sourceSize.height: implicitHeight
                //                        sourceSize.width: implicitWidth>Screen.width ? Screen.width : implicitWidth

                //                        //asynchronous for LOCAL filesystem, http are always loaded asynchonously.
                //                        //anyway, we set this
                //                        asynchronous: true

                //                        source: {
                //                            toLarge(model.thumbnail_pic)
                //                        }

                //                        onStatusChanged: {
                //                            if (imageweibo.status == Image.Ready) {
                //                                runningBusyIndicator = false;
                //                            }
                //                        }

                ////                        Component.onCompleted: {
                ////                            console.log(" === onCompleted implicitWidth " + implicitWidth + " implicitHeight " + implicitHeight )
                ////                            console.log(" === onCompleted width is " + imageweibo.width + " height is " + imageweibo.height);
                ////                        }
                ////                        onImplicitWidthChanged: {
                ////                            console.log(" === onImplicitWidthChanged " + implicitWidth )
                ////                            console.log("=== onImplicitWidthChanged width is " + imageweibo.width + " height is " + imageweibo.height);
                ////                        }
                ////                        onImplicitHeightChanged: {
                ////                            console.log(" === onImplicitHeightChanged " + implicitHeight )
                ////                            console.log("=== onImplicitHeightChanged width is " + imageweibo.width + " height is " + imageweibo.height);

                ////                        }
                //                    }
                //                }
                //            }
            }
        //}
    }
}
