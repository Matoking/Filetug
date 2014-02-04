#ifndef FILEINFO_H
#define FILEINFO_H

#include <QObject>
#include <QDebug>
#include <QFileInfo>
#include <QVariantMap>
#include <QImage>
#include <QDateTime>

class FileInfo : public QObject
{
    Q_OBJECT
public:
    explicit FileInfo(QObject *parent = 0);

    Q_INVOKABLE QVariant getFileInfo(const QString &fullPath);
    Q_INVOKABLE QString getFileContent(const QString &fullPath);


    Q_INVOKABLE QString getFileFormatName(QString suffix);
    Q_INVOKABLE QString bytesToString(qint64 bytes);

    QVariantMap getFileActions(QString fullPath);

signals:

public slots:

};

#endif // FILEINFO_H
