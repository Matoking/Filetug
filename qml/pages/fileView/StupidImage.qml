import QtQuick 2.0
import Sailfish.Silica 1.0

// ABANDON ALL HOPE YE WHO ENTER HERE

Flickable {
    id: imageView

    // Current displayed image
    property string fullPath: ""

    // Image dimensions
    property double fitScale: 1

    property bool destroyAfterTransition: false

    transformOrigin: Item.TopLeft

    leftMargin: ((currentImage.scale - 1) * (currentImage.sourceSize.width / 2))
    rightMargin: 0 - ((currentImage.scale - 1) * (currentImage.sourceSize.width / 2))

    topMargin: ((currentImage.scale - 1) * (currentImage.sourceSize.height / 2))
    bottomMargin: 0 - ((currentImage.scale - 1) * (currentImage.sourceSize.height / 2))

    width: parent.width
    height: parent.height

    contentHeight: (currentImage.scale * currentImage.sourceSize.height) >= height ? (currentImage.scale * currentImage.sourceSize.height) : height
    contentWidth: (currentImage.scale * currentImage.sourceSize.width) >= width ? (currentImage.scale * currentImage.sourceSize.width) : width

    // Center image on orientation change
    onWidthChanged: {
        imageLoaded()
    }

    Image {
        id: currentImage

        asynchronous: true

        transformOrigin: Item.Center

        onScaleChanged: updateFlickableSize()

        onStatusChanged: if (currentImage.status == Image.Ready) imageLoaded()

        source: fullPath

        onActiveFocusChanged: console.log("in hte air")
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: currentImage.status == Image.Loading ? true : false
        size: BusyIndicatorSize.Large

    }

    PinchArea {
        id: pinchArea

        enabled: true

        transformOrigin: Item.Center

        pinch.target: currentImage
        pinch.dragAxis: Pinch.NoDrag

        pinch.minimumScale: fitScale
        pinch.maximumScale: 2

        pinch.minimumX: 0
        pinch.maximumX: 0
        pinch.minimumY: 0
        pinch.maximumY: 0

        onPinchFinished: updateFlickableSize()
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

    /*
     *  Image loaded; set parameters for best dragging, zooming etc.
     */
    function imageLoaded()
    {
        console.log("Loaded")
        //pinchArea.pinch.maximumX = currentImage.width * 2;
        //pinchArea.pinch.minimumX = -(currentImage.width * 2);

        //pinchArea.pinch.maximumY = currentImage.height * 2;
        //pinchArea.pinch.minimumY = -(currentImage.height * 2);

        // Calculate coordinates for fitting to screen
        var fitWidth = currentImage.sourceSize.width
        var fitHeight = currentImage.sourceSize.height

        console.log("Screen size: " + imageView.width + "x" + imageView.height)
        console.log("Original size: " + currentImage.sourceSize.width + "x" + currentImage.sourceSize.height)

        if (currentImage.sourceSize.width > imageView.width)
        {
            fitWidth = imageView.width

            fitHeight = (fitWidth * currentImage.sourceSize.height) / currentImage.sourceSize.width
        }

        if (fitHeight > parent.height)
        {
            fitHeight = imageView.height

            fitWidth = (fitHeight * currentImage.sourceSize.width) / currentImage.sourceSize.height
        }

        console.log("New size: " + fitWidth + "x" + fitHeight)

        fitScale = Math.min(fitWidth / currentImage.sourceSize.width,
                            fitHeight / currentImage.sourceSize.height)

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
        currentImage.scale = fitScale
        centerImage()
    }

    /*
     *  Center the image
     */
    function centerImage()
    {
        imageView.contentX = (currentImage.width / 2) - (Screen.width / 2)
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
     *
     *
     */
    function updateFlickableSize()
    {
        // WHAT THE FUCK
        if ((currentImage.scale * currentImage.sourceSize.height) < imageView.height)
        {
            currentImage.y = (imageView.height / 2) - ((currentImage.scale * currentImage.sourceSize.height) / 2)
            imageView.contentY = ((1 - currentImage.scale) * currentImage.sourceSize.height) / 2
        }
        else
            currentImage.y = 0

        // IS THIS SHIT
        if ((currentImage.scale * currentImage.sourceSize.width) < imageView.width)
        {
            currentImage.x = (imageView.width / 2) - ((currentImage.scale * currentImage.sourceSize.width) / 2)
            imageView.contentX = ((1 - currentImage.scale) * currentImage.sourceSize.width) / 2
        }
        else
            currentImage.x = 0

        pinchArea.x = currentImage.x
        pinchArea.y = currentImage.y

        pinchArea.width = currentImage.sourceSize.width
        pinchArea.height = currentImage.sourceSize.height

        pinchArea.scale = currentImage.scale
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
