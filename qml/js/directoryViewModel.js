/*
 *  Updates the file list
 */
function updateFileList(fileModel, path)
{
    console.log(path)
    var newFileList = fileList.getFileList(path);

    fileModel.clear();

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
                break;
        }

        console.log(entry.fullPath)

        fileModel.append(entry);
    }
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
