import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: fileDisplay

    allowedOrientations: Orientation.All

    property var isFilePage: true

    property var fileEntry: { "imageType": null }
    property var displayMode: null

    property int currentFileId: -1

    property var currentView: null

    property bool overlayUiVisible: false

    // Don't allow the file properties page to be opened if one has already been opened somewhere
    // (we don't want endlessly recursing pages)
    property bool allowPropertiesPage: false

    // An array of files of the same file type
    property var similarFileList: null

    Row {
        id: fileRow
        anchors.fill: parent
    }

    BusyIndicator {
        id: busyIndicator

        z: 100000 // THIS NIGGA BE ON TOP
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }

    Image {
        id: backArea

        x: 0
        y: 0

        height: parent.width < parent.height ? (parent.width / 5) : (parent.height / 5)
        width: parent.width < parent.height ? (parent.width / 5) : (parent.height / 5)

        source: "qrc:/icons/home"

        opacity: overlayUiVisible == true ? 0.5 : 0

        MouseArea {
            anchors.fill: parent

            propagateComposedEvents: true

            onClicked: {
                showOverlayUi()

                // Update cover
                coverModel.setCoverLabel(settings.dirPath)
                coverModel.setIconSource("qrc:/icons/directory")

                pageStack.pop()
            }
        }
    }

    Image {
        id: propertiesArea

        x: parent.width - width
        y: 0

        height: parent.width < parent.height ? (parent.width / 5) : (parent.height / 5)
        width: parent.width < parent.height ? (parent.width / 5) : (parent.height / 5)

        source: "qrc:/icons/properties"

        opacity: overlayUiVisible == true ? 0.5 : 0
        visible: false

        MouseArea {
            anchors.fill: parent

            propagateComposedEvents: true

            onClicked: {
                if (!allowPropertiesPage)
                    return

                showOverlayUi()
                openFilePropertiesPage()
            }
        }
    }

    Image {
        id: previousArea

        x: 0
        y: (parent.height / 2) - (height / 2)

        height: parent.width < parent.height ? (parent.width / 5) : (parent.height / 5)
        width: parent.width < parent.height ? (parent.width / 5) : (parent.height / 5)

        source: "qrc:/icons/previous"

        opacity: overlayUiVisible == true ? 0.5 : 0

        MouseArea {
            anchors.fill: parent

            propagateComposedEvents: true

            onClicked: {
                if (similarFileList.length <= 1)
                    return

                showOverlayUi()
                loadListFile("previous")
            }
        }
    }

    Image {
        id: nextArea

        x: parent.width - width
        y: (parent.height / 2) - (height / 2)

        height: parent.width < parent.height ? (parent.width / 5) : (parent.height / 5)
        width: parent.width < parent.height ? (parent.width / 5) : (parent.height / 5)

        source: "qrc:/icons/next"

        opacity: overlayUiVisible == true ? 0.5 : 0

        MouseArea {
            anchors.fill: parent

            propagateComposedEvents: true

            onClicked: {
                if (similarFileList.length <= 1)
                    return

                showOverlayUi()
                loadListFile("next")
            }
        }
    }

    Text {
        id: fileNameLabel

        horizontalAlignment: Text.AlignHCenter

        anchors {
            top: parent.top

            left: parent.left
            right: parent.right
        }

        height: parent.height / 10
        width: parent.width

        text: fileEntry.fileName

        color: "white"

        font.pixelSize: Theme.fontSizeExtraSmall

        style: Text.Outline
        styleColor: "black"

        visible: overlayUiVisible
    }

    Text {
        id: fileIdLabel

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignBottom

        anchors {
            bottom: parent.bottom

            left: parent.left
            right: parent.right
        }

        height: parent.height / 10
        width: parent.width

        text: (currentFileId + 1) + "/" + similarFileList.length

        color: "white"

        font.pixelSize: Theme.fontSizeExtraSmall

        style: Text.Outline
        styleColor: "black"

        visible: overlayUiVisible
    }

    Timer {
        id: overlayTimer

        interval: settings.fileOverlayPeriod * 1000

        onTriggered: hideOverlayUi()
    }

    Connections {
        target: settings

        onFileOverlayPeriodChanged: {
            overlayTimer.interval = fileOverlayPeriod * 1000
        }
    }

    // Make sure loadFile is called only when the page is first created
    onStatusChanged: if (status == PageStatus.Activating && similarFileList == null) loadFile()

    onPressed: showOverlayUi()
    onActiveFocusChanged: showOverlayUi()

    /*
     *  Loads the current file
     */
    function loadFile()
    {
        var fileView = null;

        // Get a list of similar files
        var fileListObject = fileList.getFileList(fileEntry.path, settings.browseAllFileTypes ? "all" : fileEntry.fileType)

        similarFileList = []

        for (var i=0; i < fileListObject.length; i++)
        {
            console.log(fileListObject[i].fullPath)
            similarFileList[similarFileList.length] = { "fileName": fileListObject[i].fileName,
                                                        "fileType": fileListObject[i].fileType,
                                                        "fullPath": fileListObject[i].fullPath,
                                                        "path": fileListObject[i].path }
        }

        // Create file object
        createFileObject()

        updatePage()
    }

    /*
     *  Update the page when the page container is changed
     */
    function updatePage()
    {
        // Prevent the user from infinitely opening properties pages
        if (pageStack.depth >= 3)
        {
            allowPropertiesPage = false
        }
        else
        {
            allowPropertiesPage = true
            propertiesArea.visible = true
        }
    }

    /*
     *  Create correct object based on the provided file
     */
    function createFileObject(entry)
    {
        busyIndicator.running = true

        entry = typeof entry !== 'undefined' ? entry : fileEntry

        switch (entry.fileType)
        {
            case 'image':
                var fileView = Qt.createComponent(Qt.resolvedUrl("fileView/Image.qml"))
                break;

            case 'video':
                var fileView = Qt.createComponent(Qt.resolvedUrl("fileView/Video.qml"))
                break;

            case 'audio':
                var fileView = Qt.createComponent(Qt.resolvedUrl("fileView/Audio.qml"))
                break;

            case 'text':
                var fileView = Qt.createComponent(Qt.resolvedUrl("fileView/Text.qml"))
                break;
        }

        currentFileId = getFileId(entry.fullPath)
        fileEntry = similarFileList[currentFileId]

        var fileObject = fileView.createObject(fileRow, { "fileEntry": entry })

        currentView = fileObject

        fileObject.onFileLoaded.connect(function() { busyIndicator.running = false })

        // Add a signal so we know when user taps on the screen
        fileObject.onScreenClicked.connect(function() { showOverlayUi() })

        fileObject.loadFile()

        // Update cover
        coverModel.setCoverLabel(entry.fileName)
        // Make sure the thumbnail is displayed on the cover even if the object doesn't contain
        // the thumbnail path
        if (entry.fileType == "image")
            coverModel.setIconSource("image://thumbnail/" + entry.fullPath)
        else if ('thumbnail' in entry)
            coverModel.setIconSource(entry.thumbnail)
        else
            coverModel.setIconSource("image://icons/" + entry.fileType)

        // Disable back navigation if we are displaying an image or a video
        if (entry.fileType == "image" || entry.fileType == "video")
            showNavigationIndicator = false
        else
            showNavigationIndicator = true

        var fileIndex = engine.updateCurrentFileIndex(entry.fullPath,
                                                      entry.path,
                                                      "")

        return fileObject
    }

    /*
     *  Get file's id based on this full path
     */
    function getFileId(fullPath)
    {
        for (var i=0; i < similarFileList.length; i++)
        {
            if (similarFileList[i].fullPath === fullPath)
                return i;
        }

        return -1;
    }


    /*
     *  Load next item from the file list
     */
    function loadListFile(fileId, skipAnimation, fileType)
    {
        skipAnimation = typeof skipAnimation !== 'undefined' ? skipAnimation : false
        fileType = typeof fileType !== 'undefined' ? fileType : false

        // Get the previous or next file if requested so
        if (fileId == "previous" || fileId == "next")
        {
            var collapseDirection = fileId == "previous" ? "right" : "left"

            if (fileType == "")
            {
                if (fileId === "previous")
                    fileId = currentFileId - 1
                else
                    fileId = currentFileId + 1
            }
            else
            {
                // A specific file type was requested
                var i = currentFileId
                var fileCount = 0
                var length = similarFileList.length
                var direction = fileId == "next" ? 1 : -1

                while (fileCount <= length)
                {
                    i += direction

                    if (i < 0)
                        i = similarFileList.length - 1
                    else if (i > similarFileList.length-1)
                        i = 0

                    var fileEntry = similarFileList[i]

                    if (fileEntry.fileType == fileType)
                    {
                        fileId = i
                        break
                    }
                }
            }

            console.log(fileId)
        }
        else if (fileId < currentFileId)
            var collapseDirection = "right";
        else
            var collapseDirection = "left";

        if (fileId < 0)
            fileId = similarFileList.length - 1
        else if (fileId > similarFileList.length-1)
            fileId = 0

        // If there are two pages open (eg. a transition is in progress), ignore the action
        if (fileRow.children.length >= 2)
            return;

        // Call the to-be-destroyed file page in case some cleanup procedure needs to be done
        if ('destroyView' in fileRow.children[0])
            fileRow.children[0].destroyView()

        var newFile = createFileObject(similarFileList[fileId])

        // Collapse the current directory
        if (fileRow.children.length > 1)
        {
            var currentFile = fileRow.children[0]

            // If it's an image, make sure to fit it to screen first
            if (currentFile.fileEntry.fileType == "image")
                currentFile.fitToScreen()

            if (skipAnimation)
            {
                currentFile.destroy()
                newFile.x = 0
            }
            else if (collapseDirection == "left")
            {
                currentFile.x = 0
                currentFile.collapseToLeft(true)
                newFile.x = fileDisplay.width
                newFile.collapseToLeft(false)
            }
            else
            {
                currentFile.x = 0
                currentFile.collapseToRight(true)
                newFile.x = 0 - fileDisplay.width
                newFile.collapseToRight(false)
            }
        }
    }

    /*
     *  Open the file info view
     */
    function openFilePropertiesPage()
    {
        pageStack.push(Qt.resolvedUrl("fileView/FileInfo.qml"), { "fileEntry": fileEntry })
    }

    /*
     *  Show overlay UI if it's enabled
     */
    function showOverlayUi()
    {
        overlayUiVisible = true
        overlayTimer.restart()

        if (showNavigationIndicator)
            backArea.visible = false
        else
            backArea.visible = true

        if (similarFileList.length <= 1)
        {
            previousArea.visible = false
            nextArea.visible = false
        }
        else
        {
            previousArea.visible = true
            nextArea.visible = true
        }

        // Also call a function in the file view if it exists
        if ('showOverlayUi' in currentView)
            currentView.showOverlayUi()
    }

    /*
     *  Hide the overlay UI
     */
    function hideOverlayUi()
    {
        overlayUiVisible = false

        // Also call a function in the file view if it exists
        if ('hideOverlayUi' in currentView)
            currentView.hideOverlayUi()
    }
}
