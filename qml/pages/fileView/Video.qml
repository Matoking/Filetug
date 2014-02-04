import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0

Flickable {
    id: imageView

    signal fileLoaded()
    signal screenClicked()

    // Current displayed image
    property var fileEntry: null

    property bool destroyAfterTransition: false

    width: parent.width
    height: parent.height

    MediaPlayer {
        id: video

        source: fileEntry.fullPath
    }

    VideoOutput {
        width: parent.width
        height: parent.height

        source: video
    }

    Rectangle {
        id: pauseArea

        anchors.fill: parent

        color: "black"

        opacity: 0.5

        visible: true

        MouseArea {
            id: mouseArea

            anchors.fill: parent

            onClicked: {
                video.play()
            }
        }

        Image {
            anchors.centerIn: parent

            opacity: 1

            source: "qrc:/icons/pause"
        }
    }

    Slider {
        id: timeSlider

        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingLarge

        minimumValue: 0
        maximumValue: video.duration
    }

    SmoothedAnimation {
        id: animateCollapseLeft
        target: imageView
        properties: "x"
        from: imageView.x
        to: imageView.x - imageView.width
        duration: 200
        onStopped: if (destroyAfterTransition) imageView.destroy()
    }

    SmoothedAnimation {
        id: animateCollapseRight
        target: imageView
        properties: "x"
        from: imageView.x
        to: imageView.x + imageView.width
        duration: 200
        onStopped: if (destroyAfterTransition) imageView.destroy()
    }

    function loadFile() {  } // Do nothing because it's not necessary

    function collapseToLeft(destroyAfterCollapse)
    {
        animateCollapseLeft.start()
        destroyAfterTransition = destroyAfterCollapse
    }

    function collapseToRight(destroyAfterCollapse)
    {
        animateCollapseRight.start()
        destroyAfterTransition = destroyAfterCollapse
    }
}
