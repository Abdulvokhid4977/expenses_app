import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import './transactionList.dart';
import './new_transaction.dart';
import '../models/transaction.dart';
import './chart.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();

  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      home: const MyHomePage(),
      theme: ThemeData(
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
              headline6: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              button: const TextStyle(
                color: Colors.white,
              )),
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
              .copyWith(secondary: Colors.indigo)),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final List<Transaction> transaction = [];
  bool _chartView = false;

  @override
  void initState(){
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    print(state);
  }


  List<Transaction> get _recentTransactions {
    return transaction.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime selectedDate) {
    final newTx = Transaction(
      amount: txAmount,
      date: selectedDate,
      id: DateTime.now().toString(),
      title: txTitle,
    );
    setState(() {
      transaction.add(newTx);
    });
  }

  void _startAddingNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (bctx) {
          return NewTransaction(_addNewTransaction);
        });
  }

  void deleteTx(String id) {
    setState(() {
      transaction.removeWhere((tx) => tx.id == id);
    });
  }

  List<Widget> buildLandscapeWidget(
      MediaQueryData mediaQuery, AppBar appBar, Widget txtWidget) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("View chart"),
          Switch(
            value: _chartView,
            onChanged: (val) {
              setState(() {
                _chartView = val;
              });
            },
          ),
        ],
      ),
      _chartView
          ? SizedBox(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.7,
              child: Charts(_recentTransactions),
            )
          : txtWidget,
    ];
  }

  List<Widget> buildPortraitWidget(
      MediaQueryData mediaQuery, AppBar appBar, Widget txtWidget) {
    return [
      SizedBox(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.3,
        child: Charts(_recentTransactions),
      ),
      txtWidget
    ];
  }
  Widget _buildAppBar(){
    return Platform.isIOS
        ? CupertinoNavigationBar(
      middle: const Text('Personal Expenses'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            child: const Icon(CupertinoIcons.add),
            onTap: () => _startAddingNewTransaction(context),
          ),
        ],
      ),
    )
        :AppBar(
      title: const Text('Personal Expenses'),
      actions: [
        IconButton(
          onPressed: () {
            _startAddingNewTransaction(context);
          },
          icon: const Icon(Icons.add),
        )
      ],
    ) ;
  }
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = _buildAppBar();
    final txtWidget = SizedBox(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(transaction, deleteTx),
    );

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isLandscape)
                ...buildLandscapeWidget(mediaQuery, appBar, txtWidget),
              if (!isLandscape)
                ...buildPortraitWidget(mediaQuery, appBar, txtWidget),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _startAddingNewTransaction(context);
        },
      ),
    );
  }
}
