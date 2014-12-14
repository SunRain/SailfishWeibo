import QtQuick 2.0
import Sailfish.Silica 1.0

/*
 * ImageViewer from Jolla Sailfish Gallery Component
 * With some modification
 *
 */

//TODO: 缩放小于屏幕大小的图片时候会出现图片闪烁
SilicaFlickable {
    id: flickable
    //anchors.centerIn: parent
//    anchors.fill: parent
    //property bool menuOpen: false
    property bool enableZoom: !menuOpen
    property bool scaled: false

    // maximumWidth maximumHeight用于设置FlickableView支持的最大窗口
    property int maximumWidth
    property int maximumHeight

    property string source: "" //: image.source
    property alias _source: image.source

    onSourceChanged: {
        _source = util.parseImageUrl(flickable.source);
        flickable._resetScale();
    }

    signal clicked()
    signal loadReady()

    property real _fittedScale: Math.min(flickable.width / flickable.implicitWidth, flickable.height / flickable.implicitHeight) //: Math.min(width / implicitWidth, height / implicitHeight)
    //property real _menuOpenScale //: Math.max(_viewOpenWidth / implicitWidth, _viewOpenHeight / implicitHeight)
    property real _scale

    // if those values aren't valid then fall back to the image.
    property int _actualWidth: maximumWidth > 1 ? Math.min(image.implicitWidth, flickable.maximumWidth) : image.implicitWidth
    property int _actualHeight: maximumHeight > 1 ? Math.min(image.implicitHeight, flickable.maximumHeight) : image.implicitHeight
   // property int _viewOpenWidth:  flickable.width//Screen.width
   // property int _viewOpenHeight: flickable.height/2 //Screen.height / 2

    width: Math.min(image.width > 0 ? image.width : flickable._actualWidth, flickable.maximumWidth)
    height: Math.min(image.height > 0 ? image.height : flickable._actualHeight, flickable.maximumHeight)

    implicitWidth: flickable._actualWidth
    implicitHeight: flickable._actualHeight


    contentWidth: container.width
    contentHeight: container.height


    children: ScrollDecorator {}

     interactive: scaled
     // Override SilicaFlickable's pressDelay because otherwise it will
     // block touch events going to PinchArea in certain cases.
     pressDelay: 0

//     function _updateScale() {
//         if (image.status != Image.Ready) {
//             return
//         }
//         //state = menuOpen ? "menuOpen" : "fullscreen"
//     }

    function _resetScale() {
        if (scaled) {
            _scale = _fittedScale
            scaled = false
        }
    }

    function _scaleImage(scale, center, prevCenter) {
//        if (largePhoto.source != image.source) {
//            largePhoto.source = util.parseImageUrl(image.source)
//        }

        var newWidth
        var newHeight
        var oldWidth = image.width
        var oldHeight = image.height

//      move center
        contentX += prevCenter.x - center.x
        contentY += prevCenter.y - center.y

        // Scale and bounds check the width, and then apply the same scale to height.
        newWidth = image.width * scale
        if (newWidth <= _fittedScale * flickable.implicitWidth) {
            _resetScale()
            return
        } else {
            newWidth = /*Math.min*/Math.max(newWidth, flickable._actualWidth)
            _scale = newWidth / flickable.implicitWidth
            newHeight = Math.max(image.height, Screen.height)
        }

        // scale about center
        if (newWidth > flickable.width)
            contentX -= (oldWidth - newWidth)/(oldWidth/prevCenter.x)
        if (newHeight > flickable.height)
            contentY -= (oldHeight - newHeight)/(oldHeight/prevCenter.y)

        scaled = true;
    }

    PinchArea {
        id: container
        //anchors.fill: parent
        //pinch.maximumScale: 20;
        // pinch.minimumScale: 0.2;
        // pinch.minimumRotation: 0;
        //pinch.maximumRotation: 90;
        enabled: /*!flickable.menuOpen &&*/ flickable.enableZoom && image.status == Image.Ready
        width: Math.max(flickable.width, image.width)
        height: Math.max(flickable.height, image.height)

        onPinchStarted: {
            //pinch.accepted = true;
        }
        onPinchUpdated: {
            //transformRect.scale *= pinch.scale;
            //transformRect.rotation += pinch.rotation;
             flickable._scaleImage(1.0 + pinch.scale - pinch.previousScale, pinch.center, pinch.previousCenter)
        }
        onPinchFinished: {
            //transformRect.scale *= pinch.scale;
            //transformRect.rotation += pinch.rotation;
            flickable.returnToBounds();
        }


        Image {
            id: image
            anchors.centerIn: parent
            horizontalAlignment: Image.Left
            verticalAlignment: Image.Top
            width: Math.ceil(flickable._actualWidth * flickable._scale)
            height: Math.ceil(flickable._actualHeight * flickable._scale)
            fillMode: Image.PreserveAspectFit
            //sourceSize.height: implicitHeight
            //sourceSize.width: implicitWidth>Screen.width ? Screen.width : implicitWidth
            //source: flickable._source

            //asynchronous for LOCAL filesystem, http are always loaded asynchonously.
            //anyway, we set this
            asynchronous: true

//            opacity: status == Image.Ready ? 1 : 0
//            Behavior on opacity { FadeAnimation{} }

            onStatusChanged: {
                if (image.status == Image.Ready) {
                    util.saveRemoteImage(flickable.source);
                    flickable.loadReady()
                    //flickable._fittedScale = Math.min(flickable.width / flickable.implicitWidth, flickable.height / flickable.implicitHeight)
                   // flickable._menuOpenScale = Math.max(flickable._viewOpenWidth / flickable.implicitWidth, flickable._viewOpenHeight / flickable.implicitHeight)
                    //flickable._resetScale();
                     flickable._scale = flickable._fittedScale
                }
            }
            onSourceChanged: {
                flickable.scaled = false
            }
        }

//        Image {
//            id: largePhoto
//            sourceSize {
//                width: 3264
//                height: 3264
//            }
//            cache: false
//            asynchronous: true
//            anchors.fill: container //image
//            onStatusChanged: {
//                if (image.status == Image.Ready) {
//                    console.log("===== image ready")
//                }
//            }
//            z: 1
//        }

        MouseArea {
            anchors.fill: parent
            enabled: !flickable.scaled
            onCanceled: {
                flickable.clicked()
            }
        }
    }

//    states: [
//            State {
//                name: "menuOpen"
//                when: flickable.menuOpen && photo.status === Image.Ready
//                PropertyChanges {
//                    target: flickable
//                    _scale: flickable._menuOpenScale
//                    scaled: false
//                    contentX: (flickable.implicitWidth  * flickable._menuOpenScale - flickable._viewOpenWidth ) / 2
//                    contentY:  0
//                }
//            },
//            State {
//                name: "fullscreen"
//                PropertyChanges {
//                    target: flickable
//                    // 1.0 for smaller images. _fittedScale for images which are larger than view
//                    _scale: flickable._fittedScale //flickable._fittedScale >= 1 ? 1.0 : flickable._fittedScale
//                    scaled: false
//                    contentX: 0
//                    contentY: 0
//                }
//            }
//        ]

//    transitions: [
//            Transition {
//                from: '*'
//                to: 'menuOpen'
//                PropertyAnimation {
//                    target: flickable
//                    properties: "_scale,contentX,contentY"
//                    duration: 300
//                    easing.type: Easing.InOutCubic
//                }
//            },
//            Transition {
//                from: 'menuOpen'
//                to: '*'
//                PropertyAnimation {
//                    target: flickable
//                    properties: "_scale,contentX,contentY"
//                    duration: 300
//                    easing.type: Easing.InOutCubic
//                }
//            }
//        ]

}
