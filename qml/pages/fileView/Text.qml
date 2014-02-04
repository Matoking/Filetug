import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0

// ABANDON ALL HOPE YE WHO ENTER HERE

Flickable {
    id: rootView

    signal fileLoaded()
    signal screenClicked()

    // Current displayed image
    property var fileEntry: null

    property bool destroyAfterTransition: false

    contentHeight: textLabel.paintedHeight + Theme.itemSizeLarge

    width: parent.width
    height: parent.height

    MouseArea {
        id: backgroundMouseArea

        width: parent.width
        height: textLabel.paintedHeight + Theme.itemSizeLarge + Screen.height // Make sure the MouseArea covers the screen

        onClicked: screenClicked()
    }

    Text {
        id: textLabel

        y: Theme.itemSizeLarge
        width: parent.width

        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingSmall
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingSmall

        wrapMode: Text.Wrap

        color: Theme.primaryColor

        font.family: "monospace"
        font.pixelSize: Theme.fontSizeTiny
    }

    VerticalScrollDecorator { }

    SmoothedAnimation {
        id: animateCollapseLeft
        target: rootView
        properties: "x"
        from: rootView.x
        to: rootView.x - rootView.width
        duration: 200
        onStopped: if (destroyAfterTransition) rootView.destroy()
    }

    SmoothedAnimation {
        id: animateCollapseRight
        target: rootView
        properties: "x"
        from: rootView.x
        to: rootView.x + rootView.width
        duration: 200
        onStopped: if (destroyAfterTransition) rootView.destroy()
    }

    function loadFile()
    {
        var textContent = fileInfo.getFileContent(fileEntry.fullPath)

        textLabel.text = textContent

        fileLoaded()
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
}
