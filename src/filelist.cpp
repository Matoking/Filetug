#include "filelist.h"

FileList::FileList(QObject *parent) :
    QObject(parent)
{
    m_showHiddenFiles = false;

    m_sortBy = "";
    m_sortOrder = "";
    m_dirOrder = "";

    QStringList imageFormats;
    imageFormats << "image" << "png" << "jpg" << "jpeg" << "gif" << "svg";

    QStringList videoFormats;
    videoFormats << "video" << "mpg" << "avi" << "mov" << "3gp" << "mp4" << "mkv" << "wmv";

    QStringList audioFormats;
    audioFormats << "audio" << "mp3" << "ogg" << "wav";

    QStringList packageFormats;
    packageFormats << "package" << "apk" << "rpm";

    QStringList textFormats;
    textFormats << "text" << "txt" << "conf" << "xml";

    fileFormats.append(imageFormats);
    fileFormats.append(videoFormats);
    fileFormats.append(audioFormats);
    fileFormats.append(packageFormats);
    fileFormats.append(textFormats);
}

/*
 *  Get the directory that's currently being viewed
 */
QString FileList::getCurrentDirectory()
{
    return m_currentPath;
}

QVariant FileList::getFileList(const QString &path, const QString &fileTypes)
{
    return QVariant::fromValue(getFileObjectList(path, fileTypes));
}

QList<QObject*> FileList::getFileObjectList(const QString &path, const QString &fileTypes)
{
    QList<FileInfoEntry*> fileInfoEntryList = getFileInfoEntryList(path, fileTypes);

    QList<QObject*> fileObjectList;

    for (int i=0; i < fileInfoEntryList.length(); i++)
    {
        fileObjectList.append(fileInfoEntryList.at(i));
    }

    return fileObjectList;
}

QList<FileInfoEntry*> FileList::getFileInfoEntryList(const QString &path, const QString &fileTypes)
{
    qDebug() << "Getting file list for " << path.toLatin1();

    qDebug() << m_sortOrder.toLatin1() << m_sortBy.toLatin1();

    QString mapLabel = QString("%1:%2").arg(fileTypes, path);

    QStringList allowedFileTypes = fileTypes.split(",");

    m_currentDirFileTypes.clear();

    if (allowedFileTypes.at(0) == "")
        allowedFileTypes.clear();
    else if (allowedFileTypes.at(0) == "all") // all is the same as image, audio, video, text
    {
        allowedFileTypes << "image" << "audio" << "video" << "text";
    }

    QDir dir(path);

    if (!dir.exists())
        return QList<FileInfoEntry*>();

    // Set sorting settings
    QDir::SortFlags sortFlags = 0;

    if (m_sortBy == "name")
        sortFlags = sortFlags | QDir::Name;
    else if (m_sortBy == "time")
        sortFlags = sortFlags | QDir::Time;
    else if (m_sortBy == "size")
        sortFlags = sortFlags | QDir::Size;
    else if (m_sortBy == "type")
        sortFlags = sortFlags | QDir::Type;

    if (m_sortOrder == "desc")
        sortFlags = sortFlags | QDir::Reversed;

    if (m_dirOrder == "first")
        sortFlags = sortFlags | QDir::DirsFirst;
    else if (m_dirOrder == "last")
        sortFlags = sortFlags | QDir::DirsLast;

    dir.setSorting(sortFlags);

    // Set filters
    QDir::Filters filters = 0;

    filters = filters | QDir::AllEntries;

    if (m_showHiddenFiles)
        filters = filters | QDir::Hidden;

    dir.setFilter(filters);

    QFileInfoList fileInfoList;

    if (m_fileInfoEntryListMap.contains(mapLabel))
    {
        return m_fileInfoEntryListMap.value(mapLabel);
    }
    else
    {
        fileInfoList = dir.entryInfoList();
        m_fileTypes = fileTypes;

        if (m_currentPath != path)
        {
            m_currentPath = path;
            emit currentDirectoryChanged(path);
        }
    }

    QList<FileInfoEntry*> fileList;

    for (int i=0; i < fileInfoList.count(); i++)
    {
        QString fileType = "";

        QFileInfo fileInfo(fileInfoList.at(i).absoluteFilePath());

        QString absoluteFilePath = fileInfo.absoluteFilePath();

        // Filter out entries referring to current and previous directory
        if (absoluteFilePath == m_currentPath ||
            absoluteFilePath == m_currentPath.left(m_currentPath.lastIndexOf("/")) ||
            absoluteFilePath == "/.." || absoluteFilePath == "/")
            continue;

        FileInfoEntry *fileInfoEntry = new FileInfoEntry();
        fileInfoEntry->setFileName(fileInfo.fileName());
        fileInfoEntry->setFullPath(absoluteFilePath);
        fileInfoEntry->setPath(fileInfoList.at(i).absolutePath());

        bool ignore = false;

        // Check the file type
        for (int i=0; i < fileFormats.count(); i++)
        {
            if (fileInfoEntry->getFileType() != "")
                break;

            QStringList formats = fileFormats.at(i);
            QString type = formats.at(0);

            for (int ii=1; ii < formats.count(); ii++)
            {
                QString format = formats.at(ii);

                if (fileInfo.fileName().endsWith(format))
                {
                    fileType = type;

                    if (!m_currentDirFileTypes.contains(fileType))
                        m_currentDirFileTypes.append(fileType);

                    break;
                }
            }
        }

        if (fileInfo.isDir())
        {
            // Take out unnecessary directories
            if (absoluteFilePath == dir.absolutePath())
                ignore = true;

            fileType = "directory";
        }
        else if (fileInfo.isExecutable() && fileType == "")
        {
            fileType = "executable";
        }

        // If we don't have a known filetype, make it unknown
        if (fileType == "")
            fileType = "unknown";

        fileInfoEntry->setFileType(fileType);
        fileInfoEntry->setFileSize(fileInfo.size());

        // If we are filtering by file types, filter it out now
        if (allowedFileTypes.count() > 0 && !allowedFileTypes.contains(fileType))
            ignore = true;

        if (ignore)
        {
            delete fileInfoEntry;
            continue;
        }

        fileList.append(fileInfoEntry);
    }

    qDebug() << "Loaded dir " << m_currentPath.toLatin1() << ", " << fileList.count() << " entries (" << fileInfoList.count() << " files)";

    // Don't add "back" button for the root directory
    if (path != "/" && allowedFileTypes.count() == 0)
    {
        FileInfoEntry *backEntry = new FileInfoEntry();
        backEntry->setFileName("..");
        backEntry->setFileType("directory");
        dir.setSorting(0);
        dir.cdUp();
        backEntry->setFullPath(dir.absolutePath());

        fileList.prepend(backEntry);
    }

    // Remove an entry if there are already two
    if (m_fileInfoEntryListMap.count() >= 2)
        m_fileInfoEntryListMap.remove(m_fileInfoEntryListMap.keys().at(0));

    m_fileInfoEntryListMap.insert(mapLabel, fileList);

    return fileList;
}

bool FileList::containsFileType(const QString &fileType)
{
    return m_currentDirFileTypes.contains(fileType);
}

/*
 *  Get file permissions for a file as a string
 */
QString FileList::getFilePermissions(QString fullPath, bool update)
{
    if (update && m_permissionMap.contains(fullPath))
        m_permissionMap.remove(fullPath);

    if (m_permissionMap.contains(fullPath))
        return m_permissionMap.value(fullPath);
    else
    {
        QFileInfo fileInfo(fullPath);

        QString permissionString = Util::getPermissionString(fileInfo.permissions());
        m_permissionMap.insert(fullPath, permissionString);

        return permissionString;
    }
}

/*
 *  Get the last modification date for a file
 */
QString FileList::getLastModified(QString fullPath)
{
    if (m_lastModifiedMap.contains(fullPath))
        return m_lastModifiedMap.value(fullPath);
    else
    {
        QFileInfo fileInfo(fullPath);

        // Use day/month/year format because it makes more sense and anyone who's willing to tell
        // otherwise is wrong

        // Show only time if the file was modified on the same day
        bool sameDay = false;

        QDate currentDate = QDate::currentDate();

        if (currentDate.dayOfYear() == fileInfo.lastModified().date().dayOfYear() &&
            currentDate.year() == fileInfo.lastModified().date().year())
            sameDay = true;

        QString modifiedString;

        if (sameDay)
            modifiedString = fileInfo.lastModified().toString("hh:mm");
        else
            modifiedString = fileInfo.lastModified().toString("dd/MM/yyyy");

        m_lastModifiedMap.insert(fullPath, modifiedString);

        return modifiedString;
    }
}

void FileList::setShowHiddenFiles(const bool &showHiddenFiles)
{
    m_showHiddenFiles = showHiddenFiles;
    resetFileInfoEntryList();
}

void FileList::setSortBy(const QString &sortBy)
{
    m_sortBy = sortBy;
    resetFileInfoEntryList();
}

void FileList::setSortOrder(const QString &sortOrder)
{
    m_sortOrder = sortOrder;
    resetFileInfoEntryList();
}

void FileList::setDirOrder(const QString &dirOrder)
{
    m_dirOrder = dirOrder;
    resetFileInfoEntryList();
}

/*
 *  Reset the current path, forcing the file list to be retrieved again next time it's requested
 */
void FileList::resetFileInfoEntryList()
{
    m_fileInfoEntryListMap.clear();
    m_currentDirFileTypes.clear();

    m_permissionMap.clear();
    m_lastModifiedMap.clear();
}
