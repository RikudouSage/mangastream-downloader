#ifndef MISCTOOLS_H
#define MISCTOOLS_H

#include <QObject>
#include <QDesktopServices>
#include <QUrl>

class MiscTools : public QObject {
    Q_OBJECT
public:
    Q_INVOKABLE bool openDirectory(QString directory);
};

#endif // MISCTOOLS_H
