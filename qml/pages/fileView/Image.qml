import QtQuick 2.0
import Sailfish.Silica 1.0

// ABANDON ALL HOPE YE WHO ENTER HERE

Flickable {
    id: imageView

    signal fileLoaded()
    signal screenClicked()

    // Current displayed image
    property var fileEntry: null

    // Image dimensions
    property double fitScale: 1

    property bool destroyAfterTransition: false

    transformOrigin: Item.TopLeft

    leftMargin: ((imageLoader.item.scale - 1) * (imageLoader.item.sourceSize.width / 2))
    rightMargin: 0 - ((imageLoader.item.scale - 1) * (imageLoader.item.sourceSize.width / 2))

    topMargin: ((imageLoader.item.scale - 1) * (imageLoader.item.sourceSize.height / 2))
    bottomMargin: 0 - ((imageLoader.item.scale - 1) * (imageLoader.item.sourceSize.height / 2))

    width: parent.width
    height: parent.height

    contentHeight: (imageLoader.item.scale * imageLoader.item.sourceSize.height) >= height ? (imageLoader.item.scale * imageLoader.item.sourceSize.height) : height
    contentWidth: (imageLoader.item.scale * imageLoader.item.sourceSize.width) >= width ? (imageLoader.item.scale * imageLoader.item.sourceSize.width) : width

    // Center image on orientation change
    // There have to be signals for both width and height changes
    // because they don't change at the same time
    onWidthChanged: {
        imageLoaded()
    }
    onHeightChanged: {
        imageLoaded()
    }

    Component {
        id: imageComponent
        Image {
            id: image
            asynchronous: true

            transformOrigin: Item.Center

            onScaleChanged: updateFlickableSize()
            onStatusChanged: {
                if (status == Image.Ready) {
                    fileLoaded()
                    imageLoaded()
                }
            }

            source: fileEntry.fullPath
        }
    }

    Component {
        id: animatedImageComponent
        AnimatedImage {
            id: image

            transformOrigin: Item.Center

            onScaleChanged: updateFlickableSize()

            source: fileEntry.fullPath
        }
    }

    // Workaround for AnimatedImage's "asynchronous not working" bug
    // Normal images are loaded asynchronously
    // Animated images are loaded synchronously
    Loader {
        id: imageLoader
        sourceComponent: fileEntry.fullPath.substring(fileEntry.fullPath.length-3, fileEntry.fullPath.length) == "gif" ? animatedImageComponent : imageComponent
        asynchronous: fileEntry.fullPath.substring(fileEntry.fullPath.length-3, fileEntry.fullPath.length) == "gif" ? true : false
        onLoaded: {
            imageLoaded()
            imageView.fileLoaded()
        }
    }

    PinchArea {
        id: pinchArea

        enabled: true

        transformOrigin: Item.Center

        pinch.target: imageLoader.item
        pinch.dragAxis: Pinch.NoDrag

        pinch.minimumScale: fitScale
        pinch.maximumScale: 2

        pinch.minimumX: 0
        pinch.maximumX: 0
        pinch.minimumY: 0
        pinch.maximumY: 0

        onPinchFinished: updateFlickableSize()

        MouseArea {
            id: backgroundMouseArea

            // Make a colossal mouse area to allow the user to tap anywhere to activate
            // the on-screen overlay
            x: -100000
            y: -100000
            width: 200000
            height: 200000

            onClicked: screenClicked()
        }
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

    function loadFile()
    {
        if (imageLoader.status == Loader.Ready && imageLoader.item.progress == 1)
        {
            fileLoaded()
        }
    }

    /*
     *  Image loaded; set parameters for best dragging, zooming etc.
     */
    function imageLoaded()
    {
        console.log("Loaded")
        //pinchArea.pinch.maximumX = imageLoader.item.width * 2;
        //pinchArea.pinch.minimumX = -(imageLoader.item.width * 2);

        //pinchArea.pinch.maximumY = imageLoader.item.height * 2;
        //pinchArea.pinch.minimumY = -(imageLoader.item.height * 2);

        // Calculate coordinates for fitting to screen
        var fitWidth = imageLoader.item.sourceSize.width
        var fitHeight = imageLoader.item.sourceSize.height

        console.log("Screen size: " + imageView.width + "x" + imageView.height)
        console.log("Original size: " + imageLoader.item.sourceSize.width + "x" + imageLoader.item.sourceSize.height)

        if (imageLoader.item.sourceSize.width > imageView.width)
        {
            fitWidth = imageView.width

            fitHeight = (fitWidth * imageLoader.item.sourceSize.height) / imageLoader.item.sourceSize.width
        }

        if (fitHeight > parent.height)
        {
            fitHeight = imageView.height

            fitWidth = (fitHeight * imageLoader.item.sourceSize.width) / imageLoader.item.sourceSize.height
        }

        console.log("New size: " + fitWidth + "x" + fitHeight)

        fitScale = Math.min(fitWidth / imageLoader.item.sourceSize.width,
                            fitHeight / imageLoader.item.sourceSize.height)

        fitToScreen()

        updateFlickableSize()

        console.log("Scale: " + fitScale)

        //centerImage()
    }

    /*
     *  Fit the image to screen
     */
    function fitToScreen()
    {
        imageLoader.item.scale = fitScale
        centerImage()
    }

    /*
     *  Center the image
     */
    function centerImage()
    {
        imageView.contentX = (imageLoader.item.width / 2) - (Screen.width / 2)
        imageView.returnToBounds()
    }

    /*
     *  If pinching finished and the image has minimum scaling, center it
     */
    function imagePinchFinished(pinch)
    {
        imageView.returnToBounds()
    }

    /*
     *  Image scale changed, perform witchcraft to make it work somehow
     */
    function updateFlickableSize()
    {
        // WHAT THE FUCK
        if ((imageLoader.item.scale * imageLoader.item.sourceSize.height) < imageView.height)
        {
            imageLoader.item.y = (imageView.height / 2) - ((imageLoader.item.scale * imageLoader.item.sourceSize.height) / 2)
            imageView.contentY = ((1 - imageLoader.item.scale) * imageLoader.item.sourceSize.height) / 2
        }
        else
            imageLoader.item.y = 0

        // IS THIS SHIT
        if ((imageLoader.item.scale * imageLoader.item.sourceSize.width) < imageView.width)
        {
            imageLoader.item.x = (imageView.width / 2) - ((imageLoader.item.scale * imageLoader.item.sourceSize.width) / 2)
            imageView.contentX = ((1 - imageLoader.item.scale) * imageLoader.item.sourceSize.width) / 2
        }
        else
            imageLoader.item.x = 0

        pinchArea.x = imageLoader.item.x
        pinchArea.y = imageLoader.item.y

        pinchArea.width = imageLoader.item.sourceSize.width
        pinchArea.height = imageLoader.item.sourceSize.height

        pinchArea.scale = imageLoader.item.scale
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
