#ifndef COVERMODEL_H
#define COVERMODEL_H

#include <QObject>

class CoverModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString coverLabel READ getCoverLabel WRITE setCoverLabel NOTIFY coverLabelChanged)
    Q_PROPERTY(QString iconSource READ getIconSource WRITE setIconSource NOTIFY iconSourceChanged)
public:
    explicit CoverModel(QObject *parent = 0);

signals:
    void coverLabelChanged(const QString &coverLabel);
    void iconSourceChanged(const QString &iconSource);

public slots:
    // coverLabel
    void setCoverLabel(const QString &coverLabel);
    QString getCoverLabel() const;

    // iconSource
    void setIconSource(const QString &iconSource);
    QString getIconSource() const;

private:
    QString m_coverLabel;
    QString m_iconSource;
};

#endif // COVERMODEL_H
