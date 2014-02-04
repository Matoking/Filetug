#ifndef FILELIST_H
#define FILELIST_H

#include <QObject>
#include <QVariant>
#include <QList>
#include <QDir>
#include <QFileInfoList>
#include <QFileInfo>
#include <QDebug>

#include "fileinfoentry.h"

class FileList : public QObject
{
    Q_OBJECT
public:
    explicit FileList(QObject *parent = 0);

    Q_INVOKABLE QVariant getFileList(const QString &path, const QString &fileTypes = QString(""));

    Q_INVOKABLE QString getCurrentDirectory();

    QList<QObject*> getFileObjectList(const QString &path, const QString &fileTypes = QString(""));
    QList<FileInfoEntry*> getFileInfoEntryList(const QString &path, const QString &fileTypes = QString(""));

    Q_INVOKABLE bool containsFileType(const QString &fileType);

    // What file types the current dir contains
    QStringList m_currentDirFileTypes;

    QString m_currentPath;

    // Frequently accessed objects to store in memory for quicker access
    QMap<QString, QList<FileInfoEntry*> > m_fileInfoEntryListMap;

    QString m_fileTypes;

    QString m_sortBy;
    QString m_sortOrder;
    QString m_dirOrder;

private:
    QList<QStringList> fileFormats;

signals:
    void currentDirectoryChanged(const QString &currentDirectory);

public slots:
    void setSortBy(const QString &sortBy);
    void setSortOrder(const QString &sortOrder);
    void setDirOrder(const QString &dirOrder);

    void resetFileInfoEntryList();

};

#endif // FILELIST_H
