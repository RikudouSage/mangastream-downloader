#include "headers/misctools.h"
#include <QDebug>

#if defined(Q_OS_WIN)
    #define PREFIX "file:///"
#else
    #define PREFIX "file://"
#endif

bool MiscTools::openDirectory(QString directory) {
    directory = PREFIX+directory;
    return QDesktopServices::openUrl(QUrl(directory));
}
