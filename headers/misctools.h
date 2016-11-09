#ifndef MISCTOOLS_H
#define MISCTOOLS_H

#include "isdebug.h"
#include <QObject>
#include <QDesktopServices>
#include <QUrl>
#include <QString>
#include <QDir>

class MiscTools : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString appPath READ getAppPath)
    Q_PROPERTY(QString filePrefix READ getFilePrefix)
public:
    Q_INVOKABLE bool openDirectory(QString directory);
    QString getAppPath();
    QString getFilePrefix();
    Q_INVOKABLE bool isWindows();
    Q_INVOKABLE bool isDebug();
};

#endif // MISCTOOLS_H
