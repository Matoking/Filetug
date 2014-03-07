import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: mainPage

    property bool isDirectoryPage: true
    property bool pageCreated: false

    allowedOrientations: Orientation.All
    property string currentDir: settings.dirPath

    property var currentView: null

    showNavigationIndicator: false

    backNavigation: false

    VerticalScrollDecorator { }

    RemorsePopup { id: remorsePopup }

    Row {
        id: directoryListRow

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    /*DockedPanel {
        id: progressPanel

        width: parent.width
        height: Theme.itemSizeExtraLarge + Theme.paddingLarge

        dock: Dock.Top

        open: true

        ProgressCircle {
            id: progressCircle

            anchors.centerIn: parent

            NumberAnimation on value {
                from: 0
                to: 1
                duration: 1000
                running: progressPanel.expanded
                loops: Animation.Infinite
            }
        }
    }*/

    BackgroundItem {
        id: scrollToTopButton

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        width: parent.width
        height: Theme.itemSizeLarge

        visible: false

        Image {
            source: "image://theme/icon-l-up"

            visible: scrollToTopButton.visible

            anchors.centerIn: parent
        }

        onClicked: if (visible) getDirectoryView().scrollToTop()
    }

    BackgroundItem {
        id: scrollToBottomButton

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        width: parent.width
        height: Theme.itemSizeLarge

        visible: false

        Image {
            source: "image://theme/icon-l-down"

            visible: scrollToBottomButton.visible

            anchors.centerIn: parent
        }

        onClicked: if (visible) getDirectoryView().scrollToBottom()
    }

    Connections {
        target: settings
        onDirectoryViewSettingsChanged: {
            // Due to how signals can be propagated at different times, use a timer to
            // refresh the page
            refreshTimer.start()
        }
    }

    Connections {
        target: engine
        onFileOperationFinished: {
            refreshDirectoryView()
        }
    }

    Timer {
        id: refreshTimer
        interval: 50
        repeat: false
        onTriggered: {
            openDirectory(currentDir)
        }
    }

    onPageContainerChanged: {
        if (settings.showShortcutsAtStartup && !directoryPageCreated)
        {
            openShortcuts()
            directoryPageCreated = true
        }
        else
            openDirectory(settings.dirPath, "left", true)
    }

    /*
     *  Open a directory
     */
    function openDirectory(path, collapseDirection, skipAnimation, viewMode)
    {
        collapseDirection = typeof collapseDirection !== 'undefined' ? collapseDirection : "left"
        skipAnimation = typeof skipAnimation !== 'undefined' ? skipAnimation : false
        viewMode = typeof viewMode !== 'undefined' ? viewMode : settings.defaultViewMode

        // Clear the list of selected files
        clipboard.clearSelectedFiles()
        selectingItems = false

        // Reset the current file index
        engine.currentFileIndex = -1

        var component = null

        // Create the directory
        switch (viewMode)
        {
            case "list":
                component = Qt.createComponent(Qt.resolvedUrl("dirView/DirectoryListView.qml"))
                break;
            case "grid":
                component = Qt.createComponent(Qt.resolvedUrl("dirView/DirectoryGridView.qml"))
                break;
        }

        var newDir = component.createObject(directoryListRow, { "path": path, "directoryView": mainPage })

        currentView = newDir

        settings.dirPath = path

        // Update cover
        coverModel.setCoverLabel(path)
        coverModel.setIconSource("qrc:/icons/directory")

        // Collapse the current directory
        if (directoryListRow.children.length > 1)
        {
            var currentDir = directoryListRow.children[0]

            if (skipAnimation)
            {
                currentDir.destroy()
                newDir.x = 0
                newDir.loadFileList()
            }
            else if (collapseDirection == "left")
            {
                currentDir.x = 0
                currentDir.collapseToLeft(true)
                newDir.x = mainPage.width
                newDir.collapseToLeft(false)
            }
            else
            {
                currentDir.x = 0
                currentDir.collapseToRight(true)
                newDir.x = 0 - mainPage.width
                newDir.collapseToRight(false)
            }
        }

        getDirectoryView().scrollToTop()

        updateBackNavigation()
    }

    /*
     *  Open shortcuts view
     */
    function openShortcuts()
    {
        clipboard.clearSelectedFiles()
        selectingItems = false

        // Reset current file index
        engine.currentFileIndex = -1

        var component = Qt.createComponent(Qt.resolvedUrl('dirView/ShortcutsView.qml'))

        currentView = component.createObject(directoryListRow)

        // Collapse the current directory
        if (directoryListRow.children.length > 1)
        {
            var currentDir = directoryListRow.children[0]

            currentDir.x = 0
            currentDir.collapseToLeft(true)
            newView.x = mainPage.width
            newView.collapseToLeft(false)
        }

        backNavigation = false
    }

    /*
     *  Change the current directory view
     */
    function changeDirectoryView(dirView)
    {
        currentView.destroy()
        openDirectory(settings.dirPath, "left", true, dirView)
    }

    /*
     *  Refresh the directory view eg. after a file operation
     */
    function refreshDirectoryView()
    {
        fileList.resetFileInfoEntryList()
        openDirectory(settings.dirPath, "left", true)
    }

    /*
     *  Perform file operation
     */
    function performFileOperation(fileOperation)
    {
        var popupMessage = "";
        var entryCount = 0;

        switch (fileOperation)
        {
            case "delete":
                popupMessage += "Deleting "
                entryCount = clipboard.getSelectedFileCount()
                break;

            case "paste":
                popupMessage += "Copying "
                entryCount = clipboard.getClipboardFileCount()
                break;
        }

        if (entryCount == 1)
            popupMessage += entryCount + " entry"
        else
            popupMessage += entryCount + " entries"

        remorsePopup.execute(popupMessage, function() { pageStack.push(Qt.resolvedUrl("FileOperationPage.qml"), { "fileOperation": fileOperation,
                                                                                                                  "clipboard": clipboard.getClipboard(),
                                                                                                                  "clipboardDir": clipboard.getClipboardDir(),
                                                                                                                  "selectedFiles": clipboard.getSelectedFiles(),
                                                                                                                  "directory": fileList.getCurrentDirectory() } ) } )
    }

    /*
     *  Open a dialog for adding new files
     */
    function addNewFiles()
    {
        pageStack.push(Qt.resolvedUrl("NewFilesDialog.qml"), { "path": settings.dirPath })
    }

    /*
     *  Opens a dialog for renaming files
     */
    function renameFiles()
    {
        pageStack.push(Qt.resolvedUrl("FileRenameDialog.qml"), { "files": clipboard.getSelectedFiles() })
    }

    /*
     *  Start or stop selecting files
     */
    function selectFiles(start)
    {
        selectingItems = start

        clipboard.clearSelectedFiles()
    }

    /*
     *  Show the "scroll to top" button
     */
    function showScrollToTop(show)
    {
        scrollToTopButton.visible = show
    }

    function showScrollToBottom(show)
    {
        scrollToBottomButton.visible = show
    }

    /*
     *  Update the backNavigation parameter
     */
    function updateBackNavigation()
    {
        if (settings.dirPath == "/")
            backNavigation = false
        else
            backNavigation = true
    }
}
