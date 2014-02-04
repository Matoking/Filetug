#ifndef FILEINFOENTRY_H
#define FILEINFOENTRY_H

#include <QObject>

class FileInfoEntry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString fileName READ getFileName WRITE setFileName)
    Q_PROPERTY(QString fileType READ getFileType WRITE setFileType)
    Q_PROPERTY(QString fullPath READ getFullPath WRITE setFullPath)
    Q_PROPERTY(QString path READ getPath WRITE setPath)
    Q_PROPERTY(qint64 fileSize READ getFileSize WRITE setFileSize)
public:
    FileInfoEntry(QObject *parent = 0);

    // fileName
    void setFileName(const QString &fileName);
    QString getFileName() const;

    // fileType
    void setFileType(const QString &fileType);
    QString getFileType() const;

    // fullPath
    void setFullPath(const QString &fullPath);
    QString getFullPath() const;

    // path
    void setPath(const QString &path);
    QString getPath() const;

    // fileSize
    void setFileSize(const qint64 &fileSize);
    qint64 getFileSize() const;

private:
    QString m_fileName;
    QString m_fileType;
    QString m_fullPath;
    QString m_path;

    qint64 m_fileSize;

signals:

public slots:

};

#endif // FILEINFOENTRY_H
