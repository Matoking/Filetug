#ifndef UTIL_H
#define UTIL_H

#include <QString>
#include <QFile>

class Util
{
public:
    static QString getPermissionString(QFileDevice::Permissions);
};

#endif // UTIL_H
