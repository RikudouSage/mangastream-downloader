import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.2
import cz.chrastecky.img 1.0
import cz.chrastecky.mangastream 1.0

ApplicationWindow {
    readonly property string infoText: qsTr("Your manga was successfully saved to %1")

    property int marginSize: 30
    property var urls

    property string mangaTitle
    property string chapter

    visible: true
    width: 640
    height: 240
    minimumWidth: 640
    minimumHeight: 240

    function startLoading() {
        loading.visible = true;
    }

    function stopLoading() {
        loading.visible = false;
    }

    title: qsTr("MangaStream downloader")
    Label {
        id: chooselabel
        text: qsTr("Choose manga to download:")
        x: marginSize
        y: marginSize
        font.pixelSize: 25
    }

    Rectangle {
        id: loading
        anchors.fill: parent
        color: "white"
        visible: true
        z: 5000
        Label {
            text: qsTr("Loading...")
            anchors.centerIn: parent
        }
    }

    ComboBox {
        model: lmodel
        textRole: "text"
        x: chooselabel.x + chooselabel.width + marginSize
        y: marginSize + 5
        onCurrentIndexChanged: {
            if(typeof lmodel.get(currentIndex).value !== "undefined") {
                startLoading();
                lmodelChapters.clear();
                mangaTitle = lmodel.get(currentIndex).text;
                var chapters = mangastream.getListOfChapters(lmodel.get(currentIndex).value);
                var url;
                var name;
                for(var i in chapters) {
                    if(i%2 == 0) {
                        url = chapters[i];
                    } else {
                        name = chapters[i];
                        lmodelChapters.append({text: name, link: url});
                    }
                }
                chapterlabel.visible = true;
                selectChapters.visible = true;
                selectChapters.currentIndexChanged();
                stopLoading();
            }
        }
    }

    Label {
        id: chapterlabel
        text: qsTr("Choose chapter: ")
        x: marginSize
        y: chooselabel.y + chooselabel.height + marginSize
        font.pixelSize: 25
        visible: false
    }

    ImageDownloader {
        id: downloader
        onDownloadComplete: {
            info.text = infoText.arg(downloader.path);
            info.open();
        }
    }

    MessageDialog {
        id: info
        title: qsTr("Download info")
    }

    MangaStream {
        id: mangastream
    }

    ComboBox {
        id: selectChapters
        model: lmodelChapters
        textRole: "text"
        x: chapterlabel.x + chapterlabel.width + marginSize
        y: chapterlabel.y + 5
        visible: false
        onCurrentIndexChanged: {
            if(typeof lmodelChapters.get(currentIndex).link != "undefined" && lmodelChapters.get(currentIndex).text != "undefined") {
                startLoading();
                chapter = lmodelChapters.get(currentIndex).text;
                downloadButton.visible = false;
                urls = mangastream.getImages(lmodelChapters.get(currentIndex).link);
                downloadButton.visible = true;
                stopLoading();
            }
        }
    }

    Button {
        id: downloadButton
        visible: false
        text: qsTr("Download")
        x: marginSize
        y: selectChapters.y + selectChapters.height + marginSize
        onClicked: {
            startLoading();
            for(var i in urls) {
                downloader.download(urls[i], mangaTitle, chapter, urls.length);
            }
            downloader.downloadComplete();
            downloader.reset();
            stopLoading();
        }
    }

    ListModel {
        id: lmodel
    }

    ListModel {
        id: lmodelChapters
    }

    Component.onCompleted: {
        var mangaList = mangastream.getListOfManga();
        lmodel.append({text: "---", value: "---"});

        var url;
        var name;
        for(var i in mangaList) {
            if(i % 2 == 0) {
                url = mangaList[i];
            } else {
                name = mangaList[i];
                lmodel.append({text: name, value: url});
            }
        }
        stopLoading();
    }
}
