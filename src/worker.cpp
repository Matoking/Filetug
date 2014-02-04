#include "worker.h"

Worker::Worker(QObject *parent) :
    QThread(parent)
{
    m_fileOperation = None;
    m_progressText = "";
    m_currentEntry = "";
    m_progressValue = 0;
}

void Worker::run()
{
    // Perform file operation
    switch (m_fileOperation)
    {
        case Paste:
            pasteFiles();
            break;
        case Delete:
            deleteFiles();
            break;
    }
}

void Worker::startPasteProcess(QStringList entryList, QString destination, QString clipboardDir)
{
    clearFileLists();

    m_fileOperation = Paste;
    m_entryList = entryList;
    m_destination = destination;
    m_clipboardDir = clipboardDir;

    start();
}

void Worker::startDeleteProcess(QStringList entryList)
{
    clearFileLists();

    m_fileOperation = Delete;
    m_entryList = entryList;

    start();
}

/*
 *  Paste files to destination
 */
void Worker::pasteFiles(bool cut)
{
    buildFileList();

    QList<QString> directoryList;

    QDir sourceDir(m_clipboardDir);

    emit progressTextChanged(QString("Copying files..."));

    // Create a list of directories to be created
    for (int i=0; i < m_directoryList.count(); i++)
    {
        QString sourcePath = m_directoryList.at(i);
        QString newDirPath = QString("%1/%2").arg(m_destination, sourceDir.relativeFilePath(sourcePath));

        directoryList.append(newDirPath);
    }

    emit progressTextChanged("Creating directories...");

    // Create a list of files to be copied
    for (int i=0; i < m_fileList.count(); i++)
    {
        QString sourcePath = m_fileList.at(i);
        QString newFilePath = QString("%1/%2").arg(m_destination, sourceDir.relativeFilePath(sourcePath));

        m_fileMap.insert(sourcePath, newFilePath);
    }

    // First, create the directories
    for (int i = 0; i < directoryList.count(); i++)
    {
        QString newDir = directoryList.at(i);

        QDir dir(newDir);

        // If the directory already exists, skip it
        if (dir.exists())
            continue;

        bool success = dir.mkdir(newDir);

        if (!success)
            directoryErrorMap.insert(newDir, DirCreateError);
    }

    // If any of the directories couldn't be created, abort the process
    if (directoryErrorMap.count() > 0)
    {
        emit progressTextChanged("Directories couldn't be created.");
        emit fileOperationFinished();

        // Abort the process
        quit();
    }

    // Now, copy the files
    int fileCount = 0;
    QMapIterator<QString, QString> i(m_fileMap);
    while (i.hasNext())
    {
        i.next();
        fileCount++;
        QString sourceFilePath = i.key();
        QString newFilePath = i.value();

        QFile sourceFile(sourceFilePath);

        // Report the progress
        emit progressTextChanged(QString("Copying files (%1 of %2)...").arg(QString("%1").arg(fileCount),
                                                                             QString("%1").arg(m_fileMap.count())));
        emit currentEntryChanged(sourceFile.fileName());

        double progress = (double)(fileCount) / (double)m_fileMap.count();
        emit progressValueChanged(progress);

        // Copy the file
        bool success = sourceFile.copy(newFilePath);

        if (!success)
            fileErrorMap.insert(newFilePath, sourceFile.error());
    }

    // We are done
    if (fileErrorMap.count() == 0 && directoryErrorMap.count() == 0)
        emit progressTextChanged("All files were copied successfully.");
    else
        emit progressTextChanged("All files couldn't be copied successfully.");

    emit fileOperationFinished();

    // Done, time to self-destruct
    quit();
}

/*
 *  Delete files in the clipboard
 */
void Worker::deleteFiles()
{
    buildFileList();

    emit progressTextChanged(QString("Deleting files..."));

    // Start deleting files
    for (int i=0; i < m_fileList.count(); i++)
    {
        QString fullPath = m_fileList.at(i);

        QFile file(fullPath);

        // Report the progress
        emit progressTextChanged(QString("Deleting files (%1 of %2)...").arg(QString("%1").arg(i+1),
                                                                             QString("%1").arg(m_fileList.count())));
        emit currentEntryChanged(file.fileName());

        double progress = (double)(i + 1) / (double)m_fileList.count();
        emit progressValueChanged(progress);

        file.open(QIODevice::WriteOnly);

        // Remove the file
        bool success = file.remove();

        if (!success)
            fileErrorMap.insert(fullPath, file.error());
    }

    // And then delete directories
    // Reverse order so that the subdirectories are deleted first
    for (int i=m_directoryList.count()-1; i >= 0; i--)
    {
        QString fullPath = m_directoryList.at(i);

        QDir dir(fullPath);

        // If it doesn't exist, it was most likely removed earlier
        if (!dir.exists())
            continue;

        bool success = dir.rmdir(fullPath);

        if (!success)
            directoryErrorMap.insert(fullPath, DirDeleteError);

        emit progressTextChanged(QString("Deleting directories..."));
        emit currentEntryChanged(dir.dirName());
        emit progressValueChanged(-1);
    }

    // We are done
    if (fileErrorMap.count() == 0 && directoryErrorMap.count() == 0)
        emit progressTextChanged("All files were deleted successfully.");
    else
        emit progressTextChanged("All files couldn't be deleted successfully.");

    emit fileOperationFinished();

    // Done, time to self-destruct
    quit();
}

/*
 *  Builds a list of every directory and file out of the entries in the clipboard
 */
void Worker::buildFileList()
{
    for (int i=0; i < m_entryList.count(); i++)
    {
        QString entry = m_entryList.at(i);
        QFileInfo fileInfo(entry);

        if (fileInfo.isDir())
        {
            addDirectoryFiles(entry);
        }
        else
            m_fileList.append(entry);
    }

    // FILES
    qDebug() << "FILES";
    for (int i=0; i < m_fileList.count(); i++)
        qDebug() << m_fileList.at(i).toLatin1();

    // DIRECTORIES
    qDebug() << "DIRECTORIES";

    for (int i=0; i < m_directoryList.count(); i++)
        qDebug() << m_directoryList.at(i).toLatin1();
}

/*
 *  Add directories and files from specified directory
 */
void Worker::addDirectoryFiles(QString dirPath)
{
    m_directoryList.append(dirPath);

    QDir dir(dirPath);
    dir.setFilter(QDir::Hidden | QDir::AllEntries | QDir::NoDotAndDotDot); // All files need to be deleted before directories can be deleted

    QFileInfoList fileInfoList = dir.entryInfoList();

    for (int i=0; i < fileInfoList.count(); i++)
    {
        QFileInfo fileInfo = fileInfoList.at(i);
        QString absoluteFilePath = fileInfo.absoluteFilePath();

        // Take out redundant entries (why do they need to there in the first place?)
        if (absoluteFilePath == dirPath ||
            absoluteFilePath == dirPath.left(dirPath.lastIndexOf("/")) ||
            absoluteFilePath == "/.." || absoluteFilePath == "/")
            continue;

        if (m_directoryList.contains(absoluteFilePath) || m_fileList.contains(absoluteFilePath))
            continue;

        if (fileInfo.isDir())
        {
            addDirectoryFiles(absoluteFilePath);
        }
        else
            m_fileList.append(absoluteFilePath);
    }
}

/*
 *  Clear file lists
 */
void Worker::clearFileLists()
{
    m_entryList.clear();
    m_fileList.clear();
    m_directoryList.clear();

    fileErrorMap.clear();
    directoryErrorMap.clear();
}
