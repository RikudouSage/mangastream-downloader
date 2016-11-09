#include "headers/misctools.h"
#include <QDebug>

#if defined(Q_OS_WIN)
    #define PREFIX "file:///"
#else
    #define PREFIX "file://"
#endif

bool MiscTools::openDirectory(QString directory) {
    qDebug() << PREFIX;
    directory = PREFIX+directory;
    return QDesktopServices::openUrl(QUrl(directory));
}
