/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:webkit/controller/apps/contact/member_list_controller.dart';
import 'package:webkit/helpers/theme/app_style.dart';
import 'package:webkit/helpers/utils/ui_mixins.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb_item.dart';
import 'package:webkit/helpers/widgets/my_button.dart';
import 'package:webkit/helpers/widgets/my_container.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:webkit/helpers/widgets/responsive.dart';
import 'package:webkit/models/app_user.dart';
import 'package:webkit/views/layouts/layout.dart';

class MemberList extends StatefulWidget {
  const MemberList({super.key});

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList>
    with SingleTickerProviderStateMixin, UIMixin {
  late MemberListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MemberListController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return Column(
            children: [
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium(
                      "Users List",
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: "Users"),
                        MyBreadcrumbItem(name: "Users List", active: true),
                      ],
                    ),
                  ],
                ),
              ),
              MySpacing.height(flexSpacing),
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: Column(
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     // MyButton(
                    //     //   onPressed: () => showDialog(
                    //     //     context: context,
                    //     //     builder: (context) => AlertDialog(
                    //     //       clipBehavior: Clip.antiAliasWithSaveLayer,
                    //     //       title: Column(
                    //     //         crossAxisAlignment: CrossAxisAlignment.start,
                    //     //         children: [
                    //     //           MyText.titleMedium(
                    //     //             "Add item",
                    //     //           ),
                    //     //         ],
                    //     //       ),
                    //     //       titlePadding: MySpacing.xy(16, 12),
                    //     //       insetPadding: MySpacing.y(300),
                    //     //       actionsPadding: MySpacing.xy(190, 16),
                    //     //       contentPadding: MySpacing.x(16),
                    //     //       content: Column(
                    //     //         crossAxisAlignment: CrossAxisAlignment.start,
                    //     //         children: [
                    //     //           MyText.bodyMedium("Name :"),
                    //     //           MySpacing.height(8),
                    //     //           TextFormField(
                    //     //             validator: controller.basicValidator
                    //     //                 .getValidation('name'),
                    //     //             controller: controller.basicValidator
                    //     //                 .getController('name'),
                    //     //             keyboardType: TextInputType.emailAddress,
                    //     //             decoration: InputDecoration(
                    //     //               labelText: "Name",
                    //     //               labelStyle:
                    //     //                   MyTextStyle.bodySmall(xMuted: true),
                    //     //               border: outlineInputBorder,
                    //     //               contentPadding: MySpacing.all(16),
                    //     //               isCollapsed: true,
                    //     //               floatingLabelBehavior:
                    //     //                   FloatingLabelBehavior.never,
                    //     //             ),
                    //     //           ),
                    //     //           MySpacing.height(16),
                    //     //           MyText.bodyMedium("Address :"),
                    //     //           MySpacing.height(8),
                    //     //           TextFormField(
                    //     //             validator: controller.basicValidator
                    //     //                 .getValidation('address'),
                    //     //             controller: controller.basicValidator
                    //     //                 .getController('address'),
                    //     //             keyboardType: TextInputType.emailAddress,
                    //     //             decoration: InputDecoration(
                    //     //               labelText: "Address",
                    //     //               labelStyle:
                    //     //                   MyTextStyle.bodySmall(xMuted: true),
                    //     //               border: outlineInputBorder,
                    //     //               contentPadding: MySpacing.all(16),
                    //     //               isCollapsed: true,
                    //     //               floatingLabelBehavior:
                    //     //                   FloatingLabelBehavior.never,
                    //     //             ),
                    //     //           ),
                    //     //         ],
                    //     //       ),
                    //     //       actions: [
                    //     //         MyButton(
                    //     //           // onPressed: controller.onSubmit,
                    //     //           onPressed: () {
                    //     //             Navigator.pop(context);
                    //     //           },
                    //     //
                    //     //           elevation: 0,
                    //     //           backgroundColor: contentTheme.primary,
                    //     //           borderRadiusAll: AppStyle.buttonRadius.medium,
                    //     //           child: MyText.bodyMedium(
                    //     //             "Ok",
                    //     //             color: contentTheme.onPrimary,
                    //     //           ),
                    //     //         ),
                    //     //         MyButton(
                    //     //           onPressed: () {
                    //     //             Navigator.pop(context);
                    //     //           },
                    //     //           elevation: 0,
                    //     //           backgroundColor: contentTheme.primary,
                    //     //           borderRadiusAll: AppStyle.buttonRadius.medium,
                    //     //           child: MyText.bodyMedium(
                    //     //             "Cancel",
                    //     //             color: contentTheme.onPrimary,
                    //     //           ),
                    //     //         ),
                    //     //       ],
                    //     //     ),
                    //     //   ),
                    //     //   elevation: 0,
                    //     //   padding: MySpacing.xy(12, 16),
                    //     //   backgroundColor: contentTheme.primary,
                    //     //   borderRadiusAll: AppStyle.buttonRadius.medium,
                    //     //   child: Row(
                    //     //     children: [
                    //     //       Icon(
                    //     //         LucideIcons.circle_plus,
                    //     //         color: contentTheme.light,
                    //     //         size: 16,
                    //     //       ),
                    //     //       MySpacing.width(16),
                    //     //       MyText.bodySmall(
                    //     //         "Add New",
                    //     //         color: contentTheme.onPrimary,
                    //     //       ),
                    //     //     ],
                    //     //   ),
                    //     // ),
                    //     SizedBox(
                    //       width: 200,
                    //       child: TextFormField(
                    //         maxLines: 1,
                    //         style: MyTextStyle.bodyMedium(),
                    //         decoration: InputDecoration(
                    //             hintText: "search",
                    //             hintStyle: MyTextStyle.bodySmall(xMuted: true),
                    //             border: outlineInputBorder,
                    //             enabledBorder: outlineInputBorder,
                    //             focusedBorder: focusedInputBorder,
                    //             prefixIcon: const Align(
                    //                 alignment: Alignment.center,
                    //                 child: Icon(
                    //                   LucideIcons.search,
                    //                   size: 14,
                    //                 )),
                    //             prefixIconConstraints: const BoxConstraints(
                    //                 minWidth: 36,
                    //                 maxWidth: 36,
                    //                 minHeight: 32,
                    //                 maxHeight: 32),
                    //             contentPadding: MySpacing.xy(16, 12),
                    //             isCollapsed: true,
                    //             floatingLabelBehavior:
                    //                 FloatingLabelBehavior.never),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // MySpacing.height(flexSpacing),
                    FutureBuilder<List<AppUserModel>>(
                      future: controller.fetchUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text("No users found."));
                        } else {
                          final users = snapshot.data!;

                          return Padding(
                            padding: MySpacing.x(flexSpacing),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MySpacing.height(16),
                                PaginatedDataTable(
                                  arrowHeadColor: contentTheme.primary,
                                  header: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      MyText.titleLarge("Users List"),
                                      MyButton(
                                        onPressed: controller.goToDashboard,
                                        elevation: 0,
                                        padding: MySpacing.xy(20, 16),
                                        backgroundColor: contentTheme.primary,
                                        borderRadiusAll:
                                            AppStyle.buttonRadius.medium,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              LucideIcons.monitor,
                                              size: 18,
                                              color: contentTheme.light,
                                            ),
                                            MySpacing.width(8),
                                            MyText.labelMedium(
                                              'dashboard'.tr,
                                              color: contentTheme.onPrimary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  columns: [
                                    DataColumn(
                                        label: MyText.bodyMedium('Avatar',
                                            fontWeight: 600)),
                                    DataColumn(
                                        label: MyText.bodyMedium('Name',
                                            fontWeight: 600)),
                                    DataColumn(
                                        label: MyText.bodyMedium('Email',
                                            fontWeight: 600)),
                                    DataColumn(
                                        label: MyText.bodyMedium('Country',
                                            fontWeight: 600)),
                                    DataColumn(
                                        label: MyText.bodyMedium('Action',
                                            fontWeight: 600)),
                                  ],
                                  columnSpacing: 80,
                                  horizontalMargin: 28,
                                  rowsPerPage: 10,
                                  source: _UserDataSource(users, controller,context),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserDataSource extends DataTableSource {
  final List<AppUserModel> users;
  final dynamic controller;
  final BuildContext context;

  _UserDataSource(this.users, this.controller, this.context);

  @override
  DataRow getRow(int index) {
    final user = users[index];
    return DataRow(
      cells: [
        DataCell(
          MyContainer.rounded(
            height: 50,
            width: 50,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Image.network(
              user.avatarUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        DataCell(MyText.bodyMedium(user.name, fontSize: 16)),
        DataCell(MyText.bodyMedium(user.email, fontSize: 16, muted: true)),
        DataCell(MyText.bodyMedium(user.country, fontSize: 16, muted: true)),

        /// Action column with two buttons
        DataCell(
          Row(
            children: [
              MyButton(
                onPressed: () {
                  //controller.selectedUser.value = user;
                },
                elevation: 0,
                padding: MySpacing.xy(12, 8),
               // backgroundColor: contentTheme.primary,
                child: MyText.bodySmall(
                  "View Profile",
              //    color: contentTheme.primary,
                  fontWeight: 600,
                ),
              ),
              MySpacing.width(8),
              MyButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirm Block"),
                      content: Text(
                        "Are you sure you want to block ${user.name}?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Block"),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    controller.blockUser(user);
                  }
                },
                elevation: 0,
                padding: MySpacing.xy(12, 8),
                backgroundColor: Colors.red.withOpacity(0.15),
                child: MyText.bodySmall(
                  "Block",
                  color: Colors.red,
                  fontWeight: 600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => users.length;
  @override
  int get selectedRowCount => 0;
}
*/




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:webkit/controller/apps/contact/member_list_controller.dart';
import 'package:webkit/helpers/theme/app_style.dart';
import 'package:webkit/helpers/utils/ui_mixins.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb_item.dart';
import 'package:webkit/helpers/widgets/my_button.dart';
import 'package:webkit/helpers/widgets/my_container.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:webkit/helpers/widgets/responsive.dart';
import 'package:webkit/models/app_user.dart';
import 'package:webkit/views/layouts/layout.dart';

class MemberList extends StatefulWidget {
  const MemberList({super.key});

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList>
    with SingleTickerProviderStateMixin, UIMixin {
  late MemberListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MemberListController());
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF835FFF);
    final Color background = const Color(0xFFEFF1FE);
    final Color accentPink = const Color(0xFFF71E64);
    final Color darkText = const Color(0xFF222222);

    return Layout(
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return Container(
            color: background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Padding(
                  padding: MySpacing.x(flexSpacing),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText.titleLarge(
                        "User Management",
                        fontWeight: 700,
                        color: darkText,
                      ),
                      MyBreadcrumb(
                        children: [
                          MyBreadcrumbItem(name: "Users",),
                          MyBreadcrumbItem(name: "List", active: true),
                        ],
                      ),
                    ],
                  ),
                ),
                MySpacing.height(flexSpacing),

                // Users Table
                Padding(
                  padding: MySpacing.x(flexSpacing),
                  child: FutureBuilder<List<AppUserModel>>(
                    future: controller.fetchUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: MyText.bodyMedium(
                            "Error loading users: ${snapshot.error}",
                            color: accentPink,
                          ),
                        );
                      } else if (!snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return  Center(
                          child: MyText.bodyMedium("No users found."),
                        );
                      } else {
                        final users = snapshot.data!;
                        return MyContainer(
                          paddingAll: 20,
                          borderRadiusAll: 20,
                          color: Colors.white,
                          // shadow: AppStyle.boxShadow.md,
                          child: PaginatedDataTable(
                            header: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyText.titleMedium(
                                  "All Registered Users",
                                  color: darkText,
                                  fontWeight: 600,
                                ),
                                MyButton(
                                  onPressed: controller.goToDashboard,
                                  elevation: 0,
                                  padding: MySpacing.xy(20, 14),
                                  backgroundColor: primary,
                                  borderRadiusAll:
                                  AppStyle.buttonRadius.medium,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.monitor,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      MySpacing.width(8),
                                      MyText.labelMedium(
                                        "Dashboard",
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            arrowHeadColor: primary,
                            columnSpacing: 80,
                            horizontalMargin: 28,
                            rowsPerPage: 10,
                            columns: [
                              DataColumn(
                                label: MyText.bodyMedium('Image',
                                    fontWeight: 600, color: darkText),
                              ),
                              DataColumn(
                                label: MyText.bodyMedium('Name',
                                    fontWeight: 600, color: darkText),
                              ),
                              DataColumn(
                                label: MyText.bodyMedium('Email',
                                    fontWeight: 600, color: darkText),
                              ),
                              DataColumn(
                                label: MyText.bodyMedium('Country',
                                    fontWeight: 600, color: darkText),
                              ),
                              DataColumn(
                                label: MyText.bodyMedium('Action',
                                    fontWeight: 600, color: darkText),
                              ),
                            ],
                            source: _UserDataSource(users, controller, context,
                                primary, accentPink, darkText),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UserDataSource extends DataTableSource {
  final List<AppUserModel> users;
  final dynamic controller;
  final BuildContext context;
  final Color primary;
  final Color accentPink;
  final Color darkText;

  _UserDataSource(
      this.users,
      this.controller,
      this.context,
      this.primary,
      this.accentPink,
      this.darkText,
      );

  @override
  DataRow getRow(int index) {
    final user = users[index];
    return DataRow(
      cells: [
        DataCell(
          Container(
            padding: const EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                user.avatarUrl,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        DataCell(MyText.bodyMedium(user.name,
            fontSize: 16, color: darkText, fontWeight: 500)),
        DataCell(MyText.bodyMedium(user.email,
            fontSize: 15, color: Colors.black54)),
        DataCell(MyText.bodyMedium(user.country,
            fontSize: 15, color: Colors.black54)),
        DataCell(
          Row(
            children: [
              MyButton(
                onPressed: () {
                  Get.to(() => _ProfileViewPage(user: user));
                },
                elevation: 0,
                padding: MySpacing.xy(12, 8),
                backgroundColor: primary.withOpacity(0.1),
                borderRadiusAll: 10,
                child: MyText.bodySmall(
                  "View Profile",
                  color: primary,
                  fontWeight: 600,
                ),
              ),
              MySpacing.width(8),
              MyButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: MyText.titleMedium(
                        "Confirm Block",
                        color: accentPink,
                        fontWeight: 700,
                      ),
                      content: MyText.bodyMedium(
                        "Are you sure you want to block ${user.name}?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text("Block",
                              style: TextStyle(color: accentPink)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    controller.blockUser(user);
                  }
                },
                elevation: 0,
                padding: MySpacing.xy(12, 8),
                backgroundColor: accentPink.withOpacity(0.12),
                borderRadiusAll: 10,
                child: MyText.bodySmall(
                  "Block",
                  color: accentPink,
                  fontWeight: 600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => users.length;
  @override
  int get selectedRowCount => 0;
}

/// Profile View Page
class _ProfileViewPage extends StatelessWidget {
  final AppUserModel user;

  const _ProfileViewPage({required this.user});

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF835FFF);
    final Color background = const Color(0xFFEFF1FE);
    final Color darkText = const Color(0xFF222222);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text("${user.name}'s Profile"),
        backgroundColor: primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: MyContainer(
            paddingAll: 24,
            borderRadiusAll: 20,
            color: Colors.white,
            // shadow: AppStyle.boxShadow.lg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    user.avatarUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                MySpacing.height(16),
                MyText.titleLarge(user.name,
                    color: darkText, fontWeight: 700),
                MyText.bodyMedium(user.email,
                    color: Colors.black54, fontWeight: 500),
                MySpacing.height(12),
                MyText.bodyMedium("Country: ${user.country}",
                    color: darkText),
                MySpacing.height(24),
                MyButton(
                  onPressed: () => Get.back(),
                  backgroundColor: primary,
                  borderRadiusAll: 12,
                  padding: MySpacing.xy(32, 14),
                  child: MyText.bodyMedium(
                    "Back to List",
                    color: Colors.white,
                    fontWeight: 600,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
