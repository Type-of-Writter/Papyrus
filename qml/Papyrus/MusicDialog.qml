/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    Papyrus is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Papyrus is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import Qt.labs.folderlistmodel 2.1
import AsemanTools 1.0

Item {
    id: music_dialog
    width: 100
    height: 62

    property variant sizeSelector

    signal selected( string repID )

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        light: true
    }

    ListView {
        id: preference_list
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 20*Devices.density
        highlightMoveDuration: 250
        clip: true
        maximumFlickVelocity: View.flickVelocity

        property int dept: -1

        model: FolderListModel {
            showDirsFirst: true
            folder: "file://" + Devices.musicsLocation
            nameFilters: ["*.mp3","*.ogg","*.MP3","*.ogg","*.wav","*.WAV"]
            sortField: FolderListModel.Name
        }
        delegate: Rectangle {
            id: item
            width: preference_list.width
            height: 100*Devices.density
            color: press? "#3B97EC" : "#00000000"

            property string text: fileBaseName
            property string path: fileURL
            property bool directory: fileIsDir
            property bool press: false

            onPressChanged: hideRollerDialog()

            Connections{
                target: preference_list
                onMovementStarted: press = false
                onFlickStarted: press = false
            }

            Image{
                id: img
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 10*Devices.density
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                width: height*4/3
                sourceSize.width: width
                sourceSize.height: height
                source: item.directory? "files/folder.png" : "files/audio.png"
            }

            Text{
                id: txt
                anchors.left: img.right
                anchors.right: parent.right
                anchors.margins: 30*Devices.density
                y: parent.height/2 - height/2
                text: parent.text.length == 0? qsTr("Back") : parent.text
                font.pixelSize: 12*Devices.fontDensity
                font.family: AsemanApp.globalFont.family
                color: "#ffffff"
                clip: true
            }

            MouseArea{
                anchors.fill: parent
                onPressed: item.press = true
                onReleased: item.press = false
                onClicked: {
                    if( item.directory )
                        preference_list.model.folder = item.path
                    else {
                        var id = repository.copyAudioToRepository( item.path )
                        music_dialog.selected(id)

                        main.popPreference()
                        main.popPreference()
                        main.darkBackground = false
                    }
                }
            }
        }

        focus: true
        highlight: Rectangle { color: "#3B97EC"; radius: 3; smooth: true }
        currentIndex: -1
    }

    ScrollBar {
        scrollArea: preference_list; height: preference_list.height; width: 6*Devices.density
        anchors.right: preference_list.right; anchors.top: preference_list.top;color: "#ffffff"
    }

    Connections{
        target: papyrus
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title.text = qsTr("Music")
    }

    function back(){
        if( preference_list.model.parentFolder == "" ) {
            main.popPreference()
            return true
        }

        preference_list.model.folder = preference_list.model.folder+"/.."
        return false
    }

    Component.onCompleted: {
        initTranslations()
        BackHandler.pushHandler(music_dialog,music_dialog.back)
    }
}
