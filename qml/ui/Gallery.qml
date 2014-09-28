import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: gallery
    anchors.fill: parent
   // flickable: null

    //property var modelGallery
    property alias modelGallery: imageListview.model
    property var index
//    function setModel(model, index) {
////        console.log("pic_urls: ", model)
////        modelImage.clear()
////        for (var i=0; i<pic_urls.length; i++) {
////            modelImage.append( { "thumbnail_pic": pic_urls[i].thumbnail_pic } )
////        }
//        modelGallery = model
//        setNewIndex(index)
//    }
    Component.onCompleted: {
        setNewIndex(index);
    }

    function setNewIndex(imageIndex) {
        imageListview.currentIndex = imageIndex
        imageListview.positionViewAtIndex(imageListview.currentIndex, ListView.Center)
    }

    function toLarge(url) {
        var tmp = url + ""
//        console.log("search image: ", tmp.indexOf("thumbnail"))
        tmp = tmp.replace("thumbnail", "large")
//        console.log("image tmp: ", tmp)
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

       Item {
            id: flickContainer
            width: imageListview.width
            height: imageListview.height
            clip: true
            
            Loader {
                anchors.fill: parent
                sourceComponent: isGifImage(model.thumbnail_pic) ? animatedImageComponent : imageComponent
            }

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
                    BusyIndicator {
                        running: animatedImageWeibo.status != AnimatedImage.Ready
                        size: BusyIndicatorSize.Large
                        anchors.centerIn: parent
                    }
                }
            }

            Component {
                id:imageComponent
                Image {
                    id: imageweibo
                    anchors.fill: parent
                    
                    fillMode: Image.PreserveAspectFit
                    sourceSize.height: window.height * 8
                    sourceSize.width: window.height * 2
                    //asynchronous for LOCAL filesystem, http are always loaded asynchonously.
                    //anyway, we set this
                    asynchronous: true
                    
                    source: {
                        toLarge(model.thumbnail_pic)
                    }
                    BusyIndicator {
                        running: imageweibo.status != Image.Ready
                        size: BusyIndicatorSize.Large
                        anchors.centerIn: parent
                    }
                    PinchArea {
                        anchors.fill: parent
                        pinch.target: parent
                        pinch.minimumScale: 1
                        pinch.maximumScale: 4
                    }
                }
            }
        }
    }
}
