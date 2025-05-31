import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:webkit/controller/apps/contact/member_list_controller.dart';
import 'package:webkit/helpers/theme/app_style.dart';
import 'package:webkit/helpers/utils/my_shadow.dart';
import 'package:webkit/helpers/utils/ui_mixins.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb.dart';
import 'package:webkit/helpers/widgets/my_breadcrumb_item.dart';
import 'package:webkit/helpers/widgets/my_button.dart';
import 'package:webkit/helpers/widgets/my_card.dart';
import 'package:webkit/helpers/widgets/my_container.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:webkit/helpers/widgets/my_text_style.dart';
import 'package:webkit/helpers/widgets/responsive.dart';
import 'package:webkit/models/post.dart';
import 'package:webkit/views/layouts/layout.dart';

class PostList extends StatefulWidget {
  const PostList({super.key});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList>
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
                      "Post List",
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: "Post"),
                        MyBreadcrumbItem(name: "Post List", active: true),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // MyButton(
                        //   onPressed: () => showDialog(
                        //     context: context,
                        //     builder: (context) => AlertDialog(
                        //       clipBehavior: Clip.antiAliasWithSaveLayer,
                        //       title: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           MyText.titleMedium(
                        //             "Add item",
                        //           ),
                        //         ],
                        //       ),
                        //       titlePadding: MySpacing.xy(16, 12),
                        //       insetPadding: MySpacing.y(300),
                        //       actionsPadding: MySpacing.xy(190, 16),
                        //       contentPadding: MySpacing.x(16),
                        //       content: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           MyText.bodyMedium("Name :"),
                        //           MySpacing.height(8),
                        //           TextFormField(
                        //             validator: controller.basicValidator
                        //                 .getValidation('name'),
                        //             controller: controller.basicValidator
                        //                 .getController('name'),
                        //             keyboardType: TextInputType.emailAddress,
                        //             decoration: InputDecoration(
                        //               labelText: "Name",
                        //               labelStyle:
                        //                   MyTextStyle.bodySmall(xMuted: true),
                        //               border: outlineInputBorder,
                        //               contentPadding: MySpacing.all(16),
                        //               isCollapsed: true,
                        //               floatingLabelBehavior:
                        //                   FloatingLabelBehavior.never,
                        //             ),
                        //           ),
                        //           MySpacing.height(16),
                        //           MyText.bodyMedium("Address :"),
                        //           MySpacing.height(8),
                        //           TextFormField(
                        //             validator: controller.basicValidator
                        //                 .getValidation('address'),
                        //             controller: controller.basicValidator
                        //                 .getController('address'),
                        //             keyboardType: TextInputType.emailAddress,
                        //             decoration: InputDecoration(
                        //               labelText: "Address",
                        //               labelStyle:
                        //                   MyTextStyle.bodySmall(xMuted: true),
                        //               border: outlineInputBorder,
                        //               contentPadding: MySpacing.all(16),
                        //               isCollapsed: true,
                        //               floatingLabelBehavior:
                        //                   FloatingLabelBehavior.never,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       actions: [
                        //         MyButton(
                        //           // onPressed: controller.onSubmit,
                        //           onPressed: () {
                        //             Navigator.pop(context);
                        //           },
                        //
                        //           elevation: 0,
                        //           backgroundColor: contentTheme.primary,
                        //           borderRadiusAll: AppStyle.buttonRadius.medium,
                        //           child: MyText.bodyMedium(
                        //             "Ok",
                        //             color: contentTheme.onPrimary,
                        //           ),
                        //         ),
                        //         MyButton(
                        //           onPressed: () {
                        //             Navigator.pop(context);
                        //           },
                        //           elevation: 0,
                        //           backgroundColor: contentTheme.primary,
                        //           borderRadiusAll: AppStyle.buttonRadius.medium,
                        //           child: MyText.bodyMedium(
                        //             "Cancel",
                        //             color: contentTheme.onPrimary,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        //   elevation: 0,
                        //   padding: MySpacing.xy(12, 16),
                        //   backgroundColor: contentTheme.primary,
                        //   borderRadiusAll: AppStyle.buttonRadius.medium,
                        //   child: Row(
                        //     children: [
                        //       Icon(
                        //         LucideIcons.circle_plus,
                        //         color: contentTheme.light,
                        //         size: 16,
                        //       ),
                        //       MySpacing.width(16),
                        //       MyText.bodySmall(
                        //         "Add New",
                        //         color: contentTheme.onPrimary,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        SizedBox(
                          width: 200,
                          child: TextFormField(
                            maxLines: 1,
                            style: MyTextStyle.bodyMedium(),
                            decoration: InputDecoration(
                                hintText: "search",
                                hintStyle: MyTextStyle.bodySmall(xMuted: true),
                                border: outlineInputBorder,
                                enabledBorder: outlineInputBorder,
                                focusedBorder: focusedInputBorder,
                                prefixIcon: const Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      LucideIcons.search,
                                      size: 14,
                                    )),
                                prefixIconConstraints: const BoxConstraints(
                                    minWidth: 36,
                                    maxWidth: 36,
                                    minHeight: 32,
                                    maxHeight: 32),
                                contentPadding: MySpacing.xy(16, 12),
                                isCollapsed: true,
                                floatingLabelBehavior:
                                FloatingLabelBehavior.never),
                          ),
                        ),
                      ],
                    ),
                    MySpacing.height(flexSpacing),
                    FutureBuilder<List<Post>>(
                      future: controller.fetchPosts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No users found."));
                        } else {
                          final users = snapshot.data!;
                          return GridView.builder(
                            shrinkWrap: true,
                            itemCount: users.length,
                            gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 350,
                                // childAspectRatio: 1,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 320),
                            itemBuilder: (context, index) {
                              return MyCard(
                                shadow: MyShadow(elevation: 0.5),
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    MyContainer.none(
                                      paddingAll: 8,
                                      borderRadiusAll: 5,
                                      child: PopupMenuButton(
                                        offset: const Offset(0, 10),
                                        position: PopupMenuPosition.under,
                                        itemBuilder: (BuildContext context) => [
                                          PopupMenuItem(
                                              padding: MySpacing.xy(16, 8),
                                              height: 10,
                                              child: MyText.bodySmall("Action")),
                                          PopupMenuItem(
                                              padding: MySpacing.xy(16, 8),
                                              height: 10,
                                              child:
                                              MyText.bodySmall("Another action")),
                                          PopupMenuItem(
                                              padding: MySpacing.xy(16, 8),
                                              height: 10,
                                              child: MyText.bodySmall(
                                                  "Somethings else here"))
                                        ],
                                        child: Icon(LucideIcons.ellipsis, size: 18),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 200,
                                          child: Image.network(
                                            users[index].imageUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        MyText.bodyMedium(
                                          users[index].title,
                                          fontSize: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: MyText.bodyMedium(
                                                users[index].description,
                                                fontSize: 16,
                                                fontWeight: 500,
                                                muted: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
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
