import QtQuick 2.0
import Ubuntu.Components 0.1

Page {
    id: gallery
    anchors.fill: parent
    flickable: null

    property var modelGallery

    function setModel(model, index) {
//        console.log("pic_urls: ", model)
//        modelImage.clear()
//        for (var i=0; i<pic_urls.length; i++) {
//            modelImage.append( { "thumbnail_pic": pic_urls[i].thumbnail_pic } )
//        }
        modelGallery = model
        setNewIndex(index)
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

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "black"
    }

    //////////////////////////////////////////////      a listview to show the images of one weibo
    ListView {
        id: imageListview

        width: parent.width
        anchors.bottom: parent.bottom
//        anchors.bottomMargin: units.gu(2)
        anchors.top: parent.top
//        anchors.topMargin: units.gu(2)
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds
        orientation: ListView.Horizontal
        contentHeight: parent.width * count
        model: modelGallery
        delegate: delageteImage
        clip: true
        highlightFollowsCurrentItem: true
        highlightRangeMode: ListView.StrictlyEnforceRange
    }

    Component {
        id: delageteImage

        Flickable {
            id: flickContainer
            width: imageListview.width
            height: imageListview.height
            contentHeight: imageweibo.height
            contentWidth: imageweibo.width

            Image {
                id: imageweibo
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                source: {
                    toLarge(model.thumbnail_pic)
                }
            }
        }
    }

//    ListModel {
//        id: modelImage
//    }
}
