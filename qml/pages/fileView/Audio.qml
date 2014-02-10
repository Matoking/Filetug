import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0

Flickable {
    id: fileView

    signal fileLoaded()
    signal screenClicked()

    // Current displayed file
    property var fileEntry: null

    // Whether the audio has been loaded at least once, used as a workaround for autoPlay
    // not working in a suitable way
    property bool audioLoaded: false

    property bool destroyAfterTransition: false

    width: parent.width
    height: parent.height

    Audio {
        id: audio

        source: fileEntry.fullPath

        onStatusChanged: {
            if (audio.status == Audio.Loaded && audio.position == 0)
            {
                updateTrackInformation()
                fileLoaded()
            }

            if (audio.status == Audio.EndOfMedia)
            {
                getFilePage().loadListFile("next", true, "audio") // Go to the next file and skip the transition animation
            }
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: screenClicked()

        Label {
            id: audioTitleLabel

            horizontalAlignment: Text.Center

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: Theme.itemSizeLarge + Theme.paddingMedium
        }

        Label {
            id: audioAuthorLabel

            color: Theme.secondaryColor

            horizontalAlignment: Text.Center

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: audioTitleLabel.bottom
            anchors.topMargin: Theme.paddingMedium
        }

        Image {
            id: coverArt

            anchors.top: audioTitleLabel.bottom
            anchors.topMargin: Theme.paddingLarge

            height: Theme.itemSizeLarge
            width: Theme.itemSizeLarge
        }

        Slider {
            id: timeSlider

            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingMedium
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            anchors.bottom: playbackButtons.top
            anchors.bottomMargin: Theme.paddingSmall

            handleVisible: true

            valueText: "0:00"

            minimumValue: 0
            maximumValue: -1 // If both minimumValue and maximumValue are 0 the Slider goes haywire

            onReleased: audio.seek(value)
        }

        Row {
            id: playbackButtons
            spacing: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            IconButton {
                icon.source: "image://theme/icon-m-previous"
                onClicked: getFilePage().loadListFile("previous", true, "audio") // Go to the previous audio file and skip the transition animation
            }
            IconButton {
                icon.source: audio.playbackState == Audio.PlayingState ? "image://theme/icon-m-pause" : "image://theme/icon-m-play"
                onClicked: audio.playbackState == Audio.PlayingState ? audio.pause() : audio.play()
            }
            IconButton {
                icon.source: "image://theme/icon-m-next"
                onClicked: getFilePage().loadListFile("next", true, "audio") // Go to the next audio file and skip the transition animation
            }
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

    function loadFile()
    {
        if (audio.status == Audio.Loaded)
        {
            updateTrackInformation()
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
     *  Update cover art and track title information
     */
    function updateTrackInformation()
    {
        if (audio.metaData.title)
            audioTitleLabel.text = audio.metaData.title
        else
            audioTitleLabel.text = fileEntry.fileName

        if (audio.metaData.albumArtist)
            audioAuthorLabel.text = audio.metaData.albumArtist

        if (!audioLoaded && audio.playbackState != Audio.PlayingState)
        {
            audio.play()
            audioLoaded = true
        }

        console.log("URL 1 " + audio.metaData.coverArtUrlSmall)
        console.log("URL 2 " + audio.metaData.coverArtUrlLarge)
        console.log("URL 3 " + audio.metaData.posterUrl)
    }

    /*
     *  Update slider value
     */
    function updateSlider()
    {
        if (timeSlider.maximumValue != audio.duration)
        {
            timeSlider.maximumValue = audio.duration
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
            return
        }

        timeSlider.value = audio.position
    }
}
