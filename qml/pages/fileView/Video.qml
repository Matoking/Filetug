import QtQuick 2.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import QtMultimedia 5.0
import org.nemomobile.thumbnailer 1.0

Flickable {
    id: fileView

    signal fileLoaded()
    signal screenClicked()

    // Current displayed file
    property var fileEntry: null

    property bool destroyAfterTransition: false

    width: parent.width
    height: parent.height

    Thumbnail {
        id: videoThumbnail

        fillMode: Thumbnail.PreserveAspectFit

        opacity: video.playbackState == MediaPlayer.StoppedState ? 1 : 0

        sourceSize.height: Screen.height
        sourceSize.width: Screen.height

        width: parent.width
        height: parent.height

        source: video.source
    }

    MediaPlayer {
        id: video

        source: fileEntry.fullPath

        onStatusChanged: loadFile()
        onPlaybackStateChanged: if (playbackState == MediaPlayer.StoppedState) screenClicked()
    }

    // VideoOutput in QtMultimedia doesn't work yet, so use GStreamerVideoOutput instead
    GStreamerVideoOutput {
        id: videoOutput
        source: video

        width: parent.width
        height: parent.height

        Rectangle {
            id: videoOverlay

            anchors.fill: parent

            color: "black"
            opacity: 0.5

            visible: video.playbackState != MediaPlayer.PlayingState ? true : false
        }
    }

    ScreenBlank {
        suspend: video.playbackState == MediaPlayer.PlayingState
    }

    MouseArea {
        anchors.fill: parent

        onClicked: screenClicked()

        MouseArea {
            id: playArea

            anchors.centerIn: parent

            width: Theme.itemSizeLarge * 2
            height: Theme.itemSizeLarge * 2

            Image {
                anchors.centerIn: parent

                width: Theme.itemSizeMedium
                height: Theme.itemSizeMedium

                source: video.playbackState == MediaPlayer.PlayingState ? "image://theme/icon-l-pause" : "image://theme/icon-l-play"

                visible: video.playbackState != MediaPlayer.PlayingState ? true : false
            }

            onClicked: {
                if (video.playbackState == MediaPlayer.PlayingState)
                {
                    video.pause()
                    timeSlider.visible = true
                }
                else
                {
                    video.play()
                    timeSlider.visible = false
                }
            }
        }

        Slider {
            id: timeSlider

            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingMedium
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingSmall

            handleVisible: true

            valueText: "0:00"

            minimumValue: 0
            maximumValue: -1 // If both minimumValue and maximumValue are 0 the Slider goes haywire

            onReleased: video.seek(value)
        }
    }

    SmoothedAnimation {
        id: animateCollapseLeft
        target: fileView
        properties: "x"
        from: fileView.x
        to: fileView.x - fileView.width
        duration: 200
        onStopped: if (destroyAfterTransition) fileView.destroy()
    }

    SmoothedAnimation {
        id: animateCollapseRight
        target: fileView
        properties: "x"
        from: fileView.x
        to: fileView.x + fileView.width
        duration: 200
        onStopped: if (destroyAfterTransition) fileView.destroy()
    }

    Timer {
        id: updateTimer

        running: true
        interval: 50
        repeat: true

        onTriggered: updateSlider()
    }

    Component.onDestruction: destroyView()

    function loadFile()
    {
        if (video.status == MediaPlayer.Loaded)
        {
            fileLoaded()
        }
    }

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

    /*
     *  Update slider value
     */
    function updateSlider()
    {
        if (timeSlider.maximumValue != video.duration)
        {
            timeSlider.maximumValue = video.duration
        }

        // Update the value text
        var seconds = Math.floor((timeSlider.value / 1000) % 60)

        if (seconds < 10)
            seconds = "0" + seconds
        var minutes = Math.floor((timeSlider.value / 1000) / 60)
        timeSlider.valueText = minutes + ":" + seconds

        // User is using the slider, don't update the value
        if (timeSlider.down)
        {
            screenClicked()
            return
        }
        timeSlider.value = video.position
    }

    /*
     *  Show time slider, called by the parent FilePage
     */
    function showOverlayUi()
    {
        timeSlider.visible = true
    }

    /*
     *  Hide time slider, called by the parent FilePage
     */
    function hideOverlayUi()
    {
        if (video.playbackState == MediaPlayer.PlayingState && !timeSlider.down)
            timeSlider.visible = false
    }

    /*
     *  Called before a new view is created or when the view is removed, used for deleting the video object
     */
    function destroyView()
    {
        video.stop()
        video.destroy()
    }
}
