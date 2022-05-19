import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';

class SelectCategory extends StatefulWidget {
  SelectCategory({
    Key? key,
    this.setSelectedCategory,
    this.setSelectedCategories,
    this.selectedCategory,
    this.selectedCategories,
    this.next,
    this.skipIfSet,
    this.nextLabel,
  }) : super(key: key);
  final Function(TransactionCategory)? setSelectedCategory;
  final Function(List<TransactionCategory>)? setSelectedCategories;
  final TransactionCategory? selectedCategory;
  final List<TransactionCategory>? selectedCategories;
  final VoidCallback? next;
  final bool? skipIfSet;
  final String? nextLabel;

  @override
  _SelectCategoryState createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  List<TransactionCategory> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0), () {
      if (widget.selectedCategory != null && widget.skipIfSet == true) {
        Navigator.pop(context);
        if (widget.next != null) {
          widget.next!();
        }
      }
    });

    if (widget.selectedCategories != null) {
      setState(() {
        selectedCategories = widget.selectedCategories ?? [];
      });
    } else if (widget.selectedCategory != null) {
      setState(() {
        selectedCategories.add(
          widget.selectedCategory ??
              TransactionCategory(
                categoryPk: 1,
                name: "",
                dateCreated: DateTime.now(),
                income: false,
                order: 0,
              ),
        );
      });
    }
  }

  //find the selected category using selectedCategory
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionCategory>>(
        stream: database.watchAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                children: [
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: snapshot.data!
                          .asMap()
                          .map(
                            (index, category) => MapEntry(
                              index,
                              CategoryIcon(
                                categoryPk: category.categoryPk,
                                size: 50,
                                label: true,
                                onTap: () {
                                  if (widget.setSelectedCategory != null) {
                                    widget.setSelectedCategory!(category);
                                    setState(() {
                                      selectedCategories = [];
                                      selectedCategories.add(category);
                                    });
                                    Future.delayed(Duration(milliseconds: 70),
                                        () {
                                      Navigator.pop(context);
                                      if (widget.next != null) {
                                        widget.next!();
                                      }
                                    });
                                  } else if (widget.setSelectedCategories !=
                                      null) {
                                    if (selectedCategories.contains(category)) {
                                      setState(() {
                                        selectedCategories.remove(category);
                                      });
                                      widget.setSelectedCategories!(
                                          selectedCategories);
                                    } else {
                                      setState(() {
                                        selectedCategories.add(category);
                                      });
                                      widget.setSelectedCategories!(
                                          selectedCategories);
                                    }
                                  }
                                },
                                outline: selectedCategories.contains(category),
                              ),
                            ),
                          )
                          .values
                          .toList(),
                    ),
                  ),
                  widget.nextLabel != null
                      ? Column(
                          children: [
                            Container(height: 15),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 500),
                              child: selectedCategories.length > 0
                                  ? Button(
                                      key: Key("addSuccess"),
                                      label: widget.nextLabel ?? "",
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      onTap: () {
                                        if (widget.next != null) {
                                          widget.next!();
                                        }
                                      },
                                    )
                                  : Button(
                                      key: Key("addNoSuccess"),
                                      label: widget.nextLabel ?? "",
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      onTap: () {},
                                      color: Colors.grey,
                                    ),
                            )
                          ],
                        )
                      : Container()
                ],
              ),
            );
          } else {
            return Container();
          }
        });
  }
}