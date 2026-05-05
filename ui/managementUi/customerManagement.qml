import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: mainColumn

    signal openManage()

    anchors.fill: parent
    anchors.margins: 8
    spacing: 8

    property int selectedCustomerDbId: -1

    ListModel {
        id: customerModel
    }

    function clearForm() {
        selectedCustomerDbId = -1
        customerIdField.text = ""
        nameField.text = ""
        addressField.text = ""
        companyField.text = ""
        phoneField.text = ""
        emailField.text = ""
        searchField.text = ""
    }

    function loadCustomers() {
        customerModel.clear()

        if (typeof databaseManager === "undefined" || !databaseManager.getCustomers) {
            console.log("databaseManager.getCustomers() is not available yet")
            return
        }

        var customers = databaseManager.getCustomers()

        for (var i = 0; i < customers.length; i++) {
            customerModel.append(customers[i])
        }
    }

    function selectCustomer(customer) {
        selectedCustomerDbId = customer.id
        customerIdField.text = customer.id
        nameField.text = customer.name
        addressField.text = customer.address
        companyField.text = customer.company
        phoneField.text = customer.phone
        emailField.text = customer.email
    }

    function requiredFieldsFilled() {
        return nameField.text.trim() !== ""
                && addressField.text.trim() !== ""
                && companyField.text.trim() !== ""
                && phoneField.text.trim() !== ""
                && emailField.text.trim() !== ""
    }

    function saveCustomer() {
        if (!requiredFieldsFilled()) {
            statusLabel.text = "Please fill all customer fields."
            return
        }

        if (typeof databaseManager === "undefined" || !databaseManager.addCustomer) {
            statusLabel.text = "databaseManager.addCustomer() is not available yet."
            return
        }

        const ok = databaseManager.addCustomer(
                    nameField.text.trim(),
                    addressField.text.trim(),
                    companyField.text.trim(),
                    phoneField.text.trim(),
                    emailField.text.trim()
                    )

        if (ok) {
            statusLabel.text = "Customer saved."
            clearForm()
            loadCustomers()
        } else {
            statusLabel.text = "Failed to save customer."
        }
    }

    function updateCustomer() {
        if (selectedCustomerDbId < 0) {
            statusLabel.text = "Select a customer first."
            return
        }

        if (!requiredFieldsFilled()) {
            statusLabel.text = "Please fill all customer fields."
            return
        }

        if (typeof databaseManager === "undefined" || !databaseManager.updateCustomer) {
            statusLabel.text = "databaseManager.updateCustomer() is not available yet."
            return
        }

        const ok = databaseManager.updateCustomer(
                    selectedCustomerDbId,
                    nameField.text.trim(),
                    addressField.text.trim(),
                    companyField.text.trim(),
                    phoneField.text.trim(),
                    emailField.text.trim()
                    )

        if (ok) {
            statusLabel.text = "Customer updated."
            clearForm()
            loadCustomers()
        } else {
            statusLabel.text = "Failed to update customer."
        }
    }

    function deleteCustomer() {
        if (selectedCustomerDbId < 0) {
            statusLabel.text = "Select a customer first."
            return
        }

        if (typeof databaseManager === "undefined" || !databaseManager.deleteCustomer) {
            statusLabel.text = "databaseManager.deleteCustomer() is not available yet."
            return
        }

        const ok = databaseManager.deleteCustomer(selectedCustomerDbId)

        if (ok) {
            statusLabel.text = "Customer deleted."
            clearForm()
            loadCustomers()
        } else {
            statusLabel.text = "Failed to delete customer."
        }
    }

    Component.onCompleted: loadCustomers()

    Rectangle {
        id: formPanel
        Layout.fillWidth: true
        Layout.preferredHeight: 360
        color: "#093C5D"
        radius: 4

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 10

            Label {
                text: "Customer Management"
                color: "white"
                font.pixelSize: 28
                font.bold: true
            }

            RowLayout {
                Label { text: "ID"; color: "white"; Layout.preferredWidth: 120 }
                TextField {
                    id: customerIdField
                    Layout.preferredWidth: 320
                    readOnly: true
                    color: "#5DF8D8"
                    placeholderText: "Auto"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }
            }

            RowLayout {
                Label { text: "Name"; color: "white"; Layout.preferredWidth: 120 }
                TextField {
                    id: nameField
                    Layout.preferredWidth: 420
                    color: "#5DF8D8"
                    placeholderText: "Customer name"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }
            }

            RowLayout {
                Label { text: "Address"; color: "white"; Layout.preferredWidth: 120 }
                TextField {
                    id: addressField
                    Layout.preferredWidth: 650
                    color: "#5DF8D8"
                    placeholderText: "Customer address"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }
            }

            RowLayout {
                Label { text: "Company"; color: "white"; Layout.preferredWidth: 120 }
                TextField {
                    id: companyField
                    Layout.preferredWidth: 420
                    color: "#5DF8D8"
                    placeholderText: "Company name"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }
            }

            RowLayout {
                Label { text: "Phone"; color: "white"; Layout.preferredWidth: 120 }
                TextField {
                    id: phoneField
                    Layout.preferredWidth: 320
                    color: "#5DF8D8"
                    placeholderText: "Phone number"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }

                Label { text: "Email"; color: "white"; Layout.preferredWidth: 80 }
                TextField {
                    id: emailField
                    Layout.preferredWidth: 420
                    color: "#5DF8D8"
                    placeholderText: "Email address"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }
            }

            RowLayout {
                spacing: 12

                Button { text: "Add"; onClicked: saveCustomer() }
                Button { text: "Update"; onClicked: updateCustomer() }
                Button { text: "Delete"; onClicked: deleteCustomer() }
                Button { text: "Clear"; onClicked: { clearForm(); statusLabel.text = "" } }
                Button { text: "Refresh"; onClicked: loadCustomers() }
                Button { text: "Back"; onClicked: mainColumn.openManage() }

                Label {
                    id: statusLabel
                    color: "#5DF8D8"
                    Layout.leftMargin: 20
                    text: ""
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "white"
        border.color: "#cccccc"
        radius: 4

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Label {
                    text: "Search"
                    Layout.preferredWidth: 80
                    color: "#222222"
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Search by name, company, phone, or email"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 34
                color: "#093C5D"
                radius: 3

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    Label { text: "ID"; color: "white"; font.bold: true; Layout.preferredWidth: 60 }
                    Label { text: "Name"; color: "white"; font.bold: true; Layout.preferredWidth: 180 }
                    Label { text: "Company"; color: "white"; font.bold: true; Layout.preferredWidth: 180 }
                    Label { text: "Phone"; color: "white"; font.bold: true; Layout.preferredWidth: 160 }
                    Label { text: "Email"; color: "white"; font.bold: true; Layout.preferredWidth: 220 }
                    Label { text: "Address"; color: "white"; font.bold: true; Layout.fillWidth: true }
                }
            }

            ListView {
                id: customerListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: customerModel

                delegate: Rectangle {
                    width: customerListView.width
                    height: visibleBySearch ? 42 : 0
                    visible: visibleBySearch
                    color: mouseArea.containsMouse ? "#e8f4fb" : (index % 2 === 0 ? "#ffffff" : "#f5f5f5")
                    border.color: "#dddddd"

                    property bool visibleBySearch: {
                        var q = searchField.text.toLowerCase().trim()
                        if (q === "") return true
                        return String(name).toLowerCase().indexOf(q) !== -1
                                || String(company).toLowerCase().indexOf(q) !== -1
                                || String(phone).toLowerCase().indexOf(q) !== -1
                                || String(email).toLowerCase().indexOf(q) !== -1
                                || String(address).toLowerCase().indexOf(q) !== -1
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Label { text: id; Layout.preferredWidth: 60; elide: Text.ElideRight; color: "black" }
                        Label { text: name; Layout.preferredWidth: 180; elide: Text.ElideRight; color: "black" }
                        Label { text: company; Layout.preferredWidth: 180; elide: Text.ElideRight; color: "black" }
                        Label { text: phone; Layout.preferredWidth: 160; elide: Text.ElideRight; color: "black" }
                        Label { text: email; Layout.preferredWidth: 220; elide: Text.ElideRight; color: "black" }
                        Label { text: address; Layout.fillWidth: true; elide: Text.ElideRight; color: "black" }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: selectCustomer({
                            "id": id,
                            "name": name,
                            "address": address,
                            "company": company,
                            "phone": phone,
                            "email": email
                        })
                    }
                }
            }
        }
    }
}
