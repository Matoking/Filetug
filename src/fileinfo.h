#ifndef FILEINFO_H
#define FILEINFO_H

#include <QObject>
#include <QByteArray>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QVariantMap>
#include <QImage>
#include <QDateTime>
#include <QDir>

#include "util.h"

class FileInfo : public QObject
{
    Q_OBJECT
public:
    explicit FileInfo(QObject *parent = 0);

    Q_INVOKABLE QVariant getFileInfo(const QString &fullPath);
    Q_INVOKABLE QString getFileContent(const QString &fullPath);

    Q_INVOKABLE void setFileContent(const QString &fullPath, const QString &content);

    Q_INVOKABLE QString getFileFormatName(QString suffix);
    Q_INVOKABLE QString bytesToString(qint64 bytes);

    QVariantMap getFileActions(QString fullPath);

signals:

public slots:

};

#endif // FILEINFO_H
