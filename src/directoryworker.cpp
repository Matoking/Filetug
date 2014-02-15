#include "directoryworker.h"

DirectoryWorker::DirectoryWorker(QObject *parent) :
    QThread(parent)
{
    m_showHiddenFiles = false;

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

    m_fileFormats.append(imageFormats);
    m_fileFormats.append(videoFormats);
    m_fileFormats.append(audioFormats);
    m_fileFormats.append(packageFormats);
    m_fileFormats.append(textFormats);
}

void DirectoryWorker::run()
{
    createFileInfoEntryList();
}

/*
 *  Start the worker process and get the file list
 */
void DirectoryWorker::getFileInfoEntryList(QString path)
{
    m_path = path;
}

void DirectoryWorker::startWorker()
{
    start();
}

void DirectoryWorker::setOrdering(QString sortBy, QString sortOrder, QString dirOrder)
{
    m_sortBy = sortBy;
    m_sortOrder = sortOrder;
    m_dirOrder = dirOrder;
}

void DirectoryWorker::setShowHiddenFiles(bool showHiddenFiles)
{
    m_showHiddenFiles = showHiddenFiles;
}

void DirectoryWorker::createFileInfoEntryList()
{
    qDebug() << "Getting file list for " << m_path.toLatin1();

    qDebug() << m_sortOrder.toLatin1() << m_sortBy.toLatin1();

    QDir dir(m_path);

    if (!dir.exists())
        emit fileInfoEntryListCreated(QList<FileInfoEntry*>(), m_path, QStringList());

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

    fileInfoList = dir.entryInfoList();

    QList<FileInfoEntry*> fileList;

    QStringList containedFileTypes;

    for (int i=0; i < fileInfoList.count(); i++)
    {
        QString fileType = "";

        QFileInfo fileInfo(fileInfoList.at(i).absoluteFilePath());

        QString absoluteFilePath = fileInfo.absoluteFilePath();

        // Filter out entries referring to current and previous directory
        if (absoluteFilePath == m_path ||
            absoluteFilePath == m_path.left(m_path.lastIndexOf("/")) ||
            absoluteFilePath == "/.." || absoluteFilePath == "/")
            continue;

        FileInfoEntry *fileInfoEntry = new FileInfoEntry();
        fileInfoEntry->setFileName(fileInfo.fileName());
        fileInfoEntry->setFullPath(absoluteFilePath);
        fileInfoEntry->setPath(fileInfoList.at(i).absolutePath());

        bool ignore = false;

        // Check the file type
        for (int i=0; i < m_fileFormats.count(); i++)
        {
            if (fileInfoEntry->getFileType() != "")
                break;

            QStringList formats = m_fileFormats.at(i);
            QString type = formats.at(0);

            for (int ii=1; ii < formats.count(); ii++)
            {
                QString format = formats.at(ii);

                if (fileInfo.fileName().endsWith(format))
                {
                    fileType = type;

                    if (!containedFileTypes.contains(fileType))
                        containedFileTypes.append(fileType);

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

        fileList.append(fileInfoEntry);
    }

    qDebug() << "Loaded dir " << m_path.toLatin1() << ", " << fileList.count() << " entries (" << fileInfoList.count() << " files)";

    // Don't add "back" button for the root directory
    if (m_path != "/")
    {
        FileInfoEntry *backEntry = new FileInfoEntry();
        backEntry->setFileName("..");
        backEntry->setFileType("directory");
        dir.setSorting(0);
        dir.cdUp();
        backEntry->setFullPath(dir.absolutePath());

        fileList.prepend(backEntry);
    }

    emit fileInfoEntryListCreated(fileList, m_path, containedFileTypes);
}
