#include "fileengine.h"

FileEngine::FileEngine(QObject *parent) :
    QObject(parent)
{
    m_currentFileIndex = -1;

    fileList = new FileList();
    fileInfo = new FileInfo();
    fileProcess = new FileProcess();
    clipboard = new Clipboard();
    settings = new Settings();
    coverModel = new CoverModel();

    fileList->setShowHiddenFiles(settings->getShowHiddenFiles());
    fileList->setSortBy(settings->getSortBy());
    fileList->setSortOrder(settings->getSortOrder());
    fileList->setDirOrder(settings->getDirOrder());

    connect(settings, SIGNAL(showHiddenFilesChanged(bool)), fileList, SLOT(setShowHiddenFiles(bool)));
    connect(settings, SIGNAL(sortByChanged(QString)), fileList, SLOT(setSortBy(QString)));
    connect(settings, SIGNAL(sortOrderChanged(QString)), fileList, SLOT(setSortOrder(QString)));
    connect(settings, SIGNAL(dirOrderChanged(QString)), fileList, SLOT(setDirOrder(QString)));
    connect(settings, SIGNAL(directoryViewSettingsChanged()), fileList, SLOT(resetFileInfoEntryList()));

    connect(fileList, SIGNAL(currentDirectoryChanged(QString)), coverModel, SLOT(setCoverLabel(QString)));
}

void FileEngine::updateCurrentFileIndex(const QString &fullPath,
                                        const QString &path,
                                        const QString &fileTypes)
{
    QList<FileInfoEntry*> fileInfoList = fileList->getFileInfoEntryList(path, fileTypes);

    int currentFileIndex = getCurrentFileIndex();

    // If current file index is above 2, try
    if (currentFileIndex > 2)
    {
        for (int i=currentFileIndex-1; i < currentFileIndex+2; i++)
        {
            // Don't go out of bounds
            if (i <= fileInfoList.length() - 1 && i >= 0)
            {
                FileInfoEntry *fileInfoEntry = fileInfoList.at(i);

                if (fileInfoEntry->getFullPath() == fullPath)
                {
                    setCurrentFileIndex(i);
                    return;
                }
            }
        }
    }

    for (int i=0; i < fileInfoList.length(); i++)
    {
        FileInfoEntry *fileInfoEntry = fileInfoList.at(i);

        if (fileInfoEntry->getFullPath() == fullPath)
        {
            setCurrentFileIndex(i);
            return;
        }
    }

}

void FileEngine::performFileOperation(const QString &fileOperation,
                                      const QStringList &clipboardList,
                                      const QString &clipboardDir,
                                      const QStringList &selectedFiles,
                                      const QString &directory)
{
    Worker *worker = new Worker();

    connect(worker, SIGNAL(progressTextChanged(QString)), this, SIGNAL(progressTextChanged(QString)));
    connect(worker, SIGNAL(currentEntryChanged(QString)), this, SIGNAL(currentEntryChanged(QString)));
    connect(worker, SIGNAL(progressValueChanged(double)), this, SIGNAL(progressValueChanged(double)));

    connect(worker, SIGNAL(fileOperationFinished()), this, SIGNAL(fileOperationFinished()));

    if (fileOperation == "paste")
    {
        bool cut = false;
        if (clipboard->getFileOperation() == "cut")
            cut = true;

        worker->startPasteProcess(clipboardList, directory, clipboardDir, cut);
    }
    else if (fileOperation == "delete")
    {
        worker->startDeleteProcess(selectedFiles);
    }
}

void FileEngine::resetCurrentFileIndex()
{
    setCurrentFileIndex(-1);
}

/*
 *  Rename files
 */
void FileEngine::renameFiles(const QString &jsonString)
{
    QVariantList fileList = QJsonDocument::fromJson(QByteArray(jsonString.toLatin1())).array().toVariantList();

    for (int i=0; i < fileList.length(); i++)
    {
        QMap<QString, QVariant> fileMap = fileList.at(i).toMap();

        QString sourceFullPath = fileMap.value("sourceFullPath").toString();
        QString sourceName = fileMap.value("sourceName").toString();
        QString newName = fileMap.value("newName").toString();

        // Load the file
        QFile file(sourceFullPath);

        bool success = file.rename(sourceFullPath.replace(sourceName, newName));
    }
}

/*
 *  Create files/directories based on the provided array
 */
void FileEngine::createEntries(const QString &jsonString)
{
    QVariantList entryList = QJsonDocument::fromJson(QByteArray(jsonString.toLatin1())).array().toVariantList();

    for (int i=0; i < entryList.length(); i++)
    {
        QMap<QString, QVariant> entryMap = entryList.at(i).toMap();

        QString type = entryMap.value("type").toString();
        QString path = entryMap.value("path").toString();
        QString name = entryMap.value("name").toString();

        // Create directories
        if (type == "directory")
        {
            QDir dir(path);
            bool success = dir.mkdir(QString("%1/%2").arg(path, name));
        }
    }
}

/*
 *  Copies a string to the clipboard
 */
void FileEngine::copyToClipboard(const QString &string)
{
    QClipboard *clipboard = QGuiApplication::clipboard();

    clipboard->setText(string);
}

/*
 *  currentFileIndex - the file index for the currently opened item
 */
void FileEngine::setCurrentFileIndex(const int &currentFileIndex)
{
    if (m_currentFileIndex != currentFileIndex)
    {
        m_currentFileIndex = currentFileIndex;
        emit currentFileIndexChanged(currentFileIndex);
    }
}

int FileEngine::getCurrentFileIndex() const
{
    return m_currentFileIndex;
}
