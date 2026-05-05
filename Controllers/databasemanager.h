#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QVariantList>

class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseManager(QObject *parent = nullptr);


    // Items
    Q_INVOKABLE bool openDatabase();
    Q_INVOKABLE bool addItem(QString itemId,
                             QString itemName,
                             QString brand,
                             QString category,
                             double buyPrice,
                             double sellPrice,
                             QString description,
                             int stock,
                             QString qtyType);
    Q_INVOKABLE QVariantList getItems();

    // Customer

    Q_INVOKABLE bool addCustomer(QString name,
                                 QString address,
                                 QString company,
                                 QString phone,
                                 QString email);

    Q_INVOKABLE QVariantList getCustomers();

    Q_INVOKABLE bool updateCustomer(int id,
                                    QString name,
                                    QString address,
                                    QString company,
                                    QString phone,
                                    QString email);

    Q_INVOKABLE bool deleteCustomer(int id);

    // Transactions

    Q_INVOKABLE bool addTransaction(QString invoiceNo,
                                    QString date,
                                    QString customerName,
                                    double subtotal,
                                    double tax,
                                    double discount,
                                    double total,
                                    double cash,
                                    double debt,
                                    QVariantList items);

    Q_INVOKABLE QVariantList getTransactions();

    Q_INVOKABLE QVariantList getTransactionItems(int transactionId);

    Q_INVOKABLE bool deleteTransaction(int transactionId);

    Q_INVOKABLE bool updateTransaction(int transactionId,
                                       QString invoiceNo,
                                       QString date,
                                       QString customerName,
                                       double subtotal,
                                       double tax,
                                       double discount,
                                       double total,
                                       double cash,
                                       double debt,
                                       QVariantList items);



signals:
    void databaseOpened();
    void databaseError(QString message);

private:
    QSqlDatabase db;
    bool createTables();
};

#endif