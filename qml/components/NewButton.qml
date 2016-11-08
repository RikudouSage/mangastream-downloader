import QtQuick 2.5
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0

Rectangle {
    property int paddingTopBottom: 10
    property int paddingLeftRight: 20
    property alias text: label.text
    property alias font: label.font

    property color borderColor: "black"
    property int borderWidth: 1

    signal clicked()

    id: root
    width: label.width + paddingLeftRight
    height: label.height + paddingTopBottom
    color: "white"

    border.color: borderColor
    border.width: borderWidth

    Label {
        id: label
        anchors.centerIn: parent
    }

    MouseArea {
        id: mousearea
        anchors.fill: parent
        onClicked: {
            root.clicked();
        }
    }

    Component.onCompleted: {

    }
}
