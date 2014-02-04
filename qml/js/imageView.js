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
