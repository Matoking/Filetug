#include "fileinfoentry.h"

FileInfoEntry::FileInfoEntry(QObject *parent) :
    QObject(parent)
{
    m_fileName = "";
    m_fileType = "";
    m_fullPath = "";
    m_path = "";

    m_fileSize = 0;
}

/*
 *  fileName - name of the file
 */
void FileInfoEntry::setFileName(const QString &fileName)
{
    if (m_fileName != fileName)
    {
        m_fileName = fileName;
    }
}

QString FileInfoEntry::getFileName() const
{
    return m_fileName;
}

/*
 *  fileType - type of the file
 *
 *  ( image, video, directory )
 */
void FileInfoEntry::setFileType(const QString &fileType)
{
    if (m_fileType != fileType)
    {
        m_fileType = fileType;
    }
}

QString FileInfoEntry::getFileType() const
{
    return m_fileType;
}

/*
 *  fullPath - full path leading to the file, including the file name
 */
void FileInfoEntry::setFullPath(const QString &fullPath)
{
    if (m_fullPath != fullPath)
    {
        m_fullPath = fullPath;
    }
}

QString FileInfoEntry::getFullPath() const
{
    return m_fullPath;
}

/*
 *  path - the directory the file is located in
 */
void FileInfoEntry::setPath(const QString &path)
{
    if (m_path != path)
    {
        m_path = path;
    }
}

QString FileInfoEntry::getPath() const
{
    return m_path;
}

/*
 *  fileSize - size of the file in bytes
 */
void FileInfoEntry::setFileSize(const qint64 &fileSize)
{
    if (m_fileSize != fileSize)
    {
        m_fileSize = fileSize;
    }
}

qint64 FileInfoEntry::getFileSize() const
{
    return m_fileSize;
}
