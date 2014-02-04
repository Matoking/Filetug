import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        VerticalScrollDecorator {}
        Column {
            id: column
            spacing: Theme.paddingLarge
            width: parent.width
            PageHeader {
                title: "About"
            }

            Column {
                width: parent.width

                Label {
                    width: parent.width

                    text: "Filetug"

                    horizontalAlignment: Text.AlignHCenter
                }
                Label {
                    width: parent.width

                    text: "v. 0.1-2"

                    font.pixelSize: Theme.fontSizeSmall

                    horizontalAlignment: Text.AlignHCenter

                    color: Theme.secondaryColor
                }
                Label {
                    width: parent.width

                    font.pixelSize: Theme.fontSizeSmall

                    text: "Coded by Matoking"

                    horizontalAlignment: Text.AlignHCenter
                }

                SectionHeader {
                    text: "Donate"
                }

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium

                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    font.pixelSize: Theme.fontSizeSmall

                    text: "If you enjoy using this software, please consider making a donation. Every cent counts and inspires me to make this application even better. :)"
                }

                Row {
                    width: parent.width

                    Button {
                        id: bitcoinDonateButton

                        onClicked: {
                            bitcoinDonateColumn.visible = !bitcoinDonateColumn.visible
                            paypalDonateColumn.visible = false
                        }

                        width: (parent.width / 2) - Theme.paddingMedium
                        text: "Bitcoin"
                    }

                    Button {
                        id: paypalDonateButton

                        onClicked: {
                            paypalDonateColumn.visible = !paypalDonateColumn.visible
                            bitcoinDonateColumn.visible = false
                        }

                        width: (parent.width / 2) - Theme.paddingMedium
                        text: "PayPal"
                    }
                }

                Column {
                    id: bitcoinDonateColumn

                    x: Theme.paddingMedium

                    spacing: Theme.paddingMedium

                    width: parent.width - (Theme.paddingMedium * 2)

                    visible: false

                    Label {
                        horizontalAlignment: Text.Center
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: Theme.fontSizeSmall

                        width: parent.width

                        text: "You can donate bitcoins to the following Bitcoin address"
                    }
                    Label {
                        color: Theme.highlightColor
                        horizontalAlignment: Text.Center
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: Theme.fontSizeSmall

                        width: parent.width

                        text: "13pYWVDt1d4gPiBM6dEnWhCJG4wdxFuEvV"
                    }
                    Button {
                        text: "Copy to clipboard"

                        anchors.horizontalCenter: parent.horizontalCenter

                        onClicked: engine.copyToClipboard("13pYWVDt1d4gPiBM6dEnWhCJG4wdxFuEvV")

                        width: parent.height > parent.width ? parent.height / 3 : parent.width / 3
                    }
                    Image {
                        source: "qrc:/images/qr_donate"

                        fillMode: Image.PreserveAspectFit

                        width: parent.width
                        height: Screen.width - (Theme.paddingMedium * 4)
                    }

                }

                Column {
                    id: paypalDonateColumn

                    x: Theme.paddingMedium

                    spacing: Theme.paddingMedium

                    width: parent.width - (Theme.paddingMedium * 2)

                    visible: false

                    Label {
                        horizontalAlignment: Text.Center
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: Theme.fontSizeSmall

                        width: parent.width

                        text: "You can donate money through PayPal using the following link"
                    }
                    Button {
                        text: "Donate"

                        anchors.horizontalCenter: parent.horizontalCenter

                        onClicked: Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TGAFUSVBRXTTW")

                        width: parent.height > parent.width ? parent.height / 3 : parent.width / 3
                    }
                }

                SectionHeader {
                    text: "Links"
                }

                BackgroundItem {
                    width: parent.width

                    onClicked: Qt.openUrlExternally("http://github.com/Matoking/FileTug")

                    Label {
                        text: "Github repository"

                        anchors.centerIn: parent
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingMedium

                        color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                }

                SectionHeader {
                    text: "License"
                }

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium

                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    x: Theme.paddingMedium

                    font.pixelSize: Theme.fontSizeTiny

                    text: "This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of this software dedicate any and all copyright interest in the software to the public domain. We make this dedication for the benefit of the public at large and to the detriment of our heirs and successors. We intend this dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this software under copyright law.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>"
                }

                SectionHeader {
                    text: "Credits"
                }

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingMedium

                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    x: Theme.paddingMedium

                    font.pixelSize: Theme.fontSizeTiny

                    text: "This software uses following works

HighContrast GNOME 3 theme icons
licensed under GNU LESSER GENERAL PUBLIC LICENSE 2.1"
                }
            }
        }
    }
}
