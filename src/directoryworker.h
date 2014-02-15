#ifndef DIRECTORYWORKER_H
#define DIRECTORYWORKER_H

#include <QObject>
#include <QDebug>
#include <QThread>
#include <QFileInfo>
#include <QDir>
#include <QStringList>

#include "fileinfoentry.h"

class DirectoryWorker : public QThread
{
    Q_OBJECT
public:
    explicit DirectoryWorker(QObject *parent = 0);

    void getFileInfoEntryList(QString path);

    void setOrdering(QString sortBy,
                     QString sortOrder,
                     QString dirOrder);

    void setShowHiddenFiles(bool showHiddenFiles);

    void startWorker();

    void createFileInfoEntryList();

public slots:

signals:
    void fileInfoEntryListCreated(QList<FileInfoEntry*> list, QString path, QStringList containedFileTypes);

protected:
    void run();

private:
    QList<QStringList> m_fileFormats;

    QString m_path;

    QString m_sortBy;
    QString m_sortOrder;

    QString m_dirOrder;

    bool m_showHiddenFiles;

};

#endif // DIRECTORYWORKER_H
