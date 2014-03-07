/*
 *  Get the file list
 */
function getFileList(fileModel, path)
{
    // Check if the file list is already available
    // If not, call an asynchronous worker to update it
    var newFileList = fileList.getFileList(path)

    if (newFileList.length == 0)
        fileList.updateFileList(path)
    else
        updateFileList(fileModel, newFileList)
}

/*
 *  Updates the file list model so that the files are displayed
 */
function updateFileList(fileModel, newFileList)
{
    fileModel.clear();

    // Check if we are using gallery mode and if there are image files in
    // the list
    if (settings.galleryMode && dirView != "grid")
    {
        // Get the file list already, so we can check if it has the file type
        if (fileList.containsFileType("image"))
        {
            // Replace the directory view
            getDirectoryPage().changeDirectoryView('grid')
            return
        }
    }

    for (var i=0; i < newFileList.length; i++)
    {
        var entry = { "fileName": newFileList[i].fileName,
                      "fileType": newFileList[i].fileType,
                      "fullPath": newFileList[i].fullPath,
                      "path": newFileList[i].path,
                      "fileSize": newFileList[i].fileSize };

        var cacheThumbnails = settings.cacheThumbnails
        var displayThumbnails = settings.displayThumbnails

        // Add thumbnail if necessary
        switch (entry.fileType)
        {
            case "image":
                if (displayThumbnails)
                {
                    if (cacheThumbnails)
                        entry.thumbnail = "image://thumbnail/" + entry.fullPath
                    else
                        entry.thumbnail = "file:///" + entry.fullPath
                }
                else
                    entry.thumbnail = "qrc:/icons/image"
                break;

            default:
                entry.thumbnail = "qrc:/icons/" + entry.fileType

                if (entry.fileType == "directory" && entry.fileName == "..")
                    entry.thumbnail = "qrc:/icons/up"

                break;
        }

        fileModel.append(entry);
    }

    fileListLoaded = true
}

/*
 *  Opens the file
 */
function openFile(entry, fileType)
{
    var directoryPage = getDirectoryPage()

    fileType = typeof fileType !== 'undefined' ? fileType : entry.fileType

    console.log("File type " + entry.fileType)

    if (entry.fileType != "directory")
    {
        console.log("Opening file " + entry.fileName)

        // What file types the file manager can display/play
        var openableFileTypes = [ "image", "audio", "video", "text" ]

        coverModel.setCoverLabel(entry.fileName)
        coverModel.setIconSource(entry.thumbnail)

        if (openableFileTypes.indexOf(fileType) != -1)
        {
            pageStack.push(Qt.resolvedUrl("../pages/FilePage.qml"), { "fileEntry": entry, "displayMode": fileType })
        }
        else
        {
            pageStack.push(Qt.resolvedUrl("../pages/fileView/FileInfo.qml"), { "fileEntry": entry, "displayMode": fileType })
        }
    }
    else
    {
        // Open the directory
        console.log("Opening directory " + entry.fileName)
        coverModel.setCoverLabel(entry.fullPath)
        coverModel.setIconSource("qrc:/icons/directory")

        if (entry.fileName != "..")
        {
            directoryPage.openDirectory(entry.fullPath, "left")
        }
        else
        {
            directoryPage.openDirectory(entry.fullPath, "right")
        }
    }
}
