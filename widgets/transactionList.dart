// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../models/transaction.dart';
import './transaction_item.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> userTransaction;
  final Function deleteTx;
  const TransactionList(this.userTransaction, this.deleteTx, {Key key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: userTransaction.isEmpty
            ? LayoutBuilder(
                builder: (ctx, constraints) {
                  return Column(
                    children: [
                      Text(
                        'Your list is empty',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: constraints.maxHeight * 0.7,
                        child: Image.asset(
                          'assets/images/waiting.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  );
                },
              )
            : ListView(
                children: userTransaction
                    .map((e) => TransactionItem(
                        key: ValueKey(e.id),
                        transaction: e,
                        deleteTx: deleteTx))
                    .toList())
        );
  }
}
