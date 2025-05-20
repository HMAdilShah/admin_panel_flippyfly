import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webkit/views/apps/CRM/contacts_page.dart';
import 'package:webkit/views/apps/CRM/opportunities.dart';
import 'package:webkit/views/apps/calender.dart';
import 'package:webkit/views/apps/chat_page.dart';
import 'package:webkit/views/apps/contacts/edit_profile.dart';
import 'package:webkit/views/apps/contacts/member_list.dart';
import 'package:webkit/views/apps/contacts/profile.dart';
import 'package:webkit/views/apps/ecommerce/add_product.dart';
import 'package:webkit/views/apps/ecommerce/customers.dart';
import 'package:webkit/views/apps/ecommerce/invoice_page.dart';
import 'package:webkit/views/apps/ecommerce/product_detail.dart';
import 'package:webkit/views/apps/ecommerce/products.dart';
import 'package:webkit/views/apps/file/file_manager.dart';
import 'package:webkit/views/apps/file/file_uploader.dart';
import 'package:webkit/views/apps/fitness/fitness_screen.dart';
import 'package:webkit/views/apps/kanban_page.dart';
import 'package:webkit/views/apps/mail_box_screen.dart';
import 'package:webkit/views/apps/projects/create_project.dart';
import 'package:webkit/views/apps/projects/project_detail.dart';
import 'package:webkit/views/apps/projects/project_list.dart';
import 'package:webkit/views/apps/shopping_customer/shopping_customer_screen.dart';
import 'package:webkit/views/auth/forgot_password.dart';
import 'package:webkit/views/auth/forgot_password_2.dart';
import 'package:webkit/views/auth/locked.dart';
import 'package:webkit/views/auth/login.dart';
import 'package:webkit/views/auth/login_2.dart';
import 'package:webkit/views/auth/register.dart';
import 'package:webkit/views/auth/register_2.dart';
import 'package:webkit/views/auth/reset_password.dart';
import 'package:webkit/views/auth/reset_password_2.dart';
import 'package:webkit/views/forms/basic_page.dart';
import 'package:webkit/views/forms/form_mask.dart';
import 'package:webkit/views/forms/quill_editor_screen.dart';
import 'package:webkit/views/forms/validation.dart';
import 'package:webkit/views/forms/wizard.dart';
import 'package:webkit/views/logistic_dashboard_screen.dart';
import 'package:webkit/views/other/basic_table.dart';
import 'package:webkit/views/other/fl_chart_screen.dart';
import 'package:webkit/views/other/google_map.dart';
import 'package:webkit/views/other/sfmap_page.dart';
import 'package:webkit/views/other/synsfusion_chart.dart';
import 'package:webkit/views/starter.dart';
import 'package:webkit/views/ui/buttons_page.dart';
import 'package:webkit/views/ui/cards_page.dart';
import 'package:webkit/views/ui/carousels.dart';
import 'package:webkit/views/ui/dialogs.dart';
import 'package:webkit/views/ui/drag_drop.dart';
import 'package:webkit/views/ui/notifications.dart';
import 'package:webkit/views/ui/reviews_page.dart';
import 'package:webkit/views/ui/tabs_page.dart';

import 'package:webkit/helpers/services/auth_services.dart';
import 'package:webkit/views/auth/locked_2.dart';
import 'package:webkit/views/dashboard.dart';
import 'package:webkit/views/error_pages/coming_soon_page.dart';
import 'package:webkit/views/error_pages/error_404.dart';
import 'package:webkit/views/error_pages/error_500.dart';
import 'package:webkit/views/error_pages/maintenance_page.dart';
import 'package:webkit/views/extra_pages/faqs_page.dart';
import 'package:webkit/views/extra_pages/pricing.dart';
import 'package:webkit/views/extra_pages/time_line_page.dart';
import 'package:webkit/views/ui/landing_page.dart';
import 'package:webkit/views/ui/nft_dashboard.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return AuthService.isLoggedIn ? null : RouteSettings(name: '/auth/login');
  }
}

getPageRoute() {
  var routes = [
    GetPage(
        name: '/',
        page: () => DashboardPage(),
        middlewares: [AuthMiddleware()]),

    GetPage(name: '/faqs', page: () => FaqsPage()),

    GetPage(
        name: '/pricing',
        page: () => Pricing(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/starter',
        page: () => Starter(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/dashboard/ecommerce',
        page: () => DashboardPage(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/dashboard/logistic',
        page: () => LogisticDashboardScreen(),
        middlewares: [AuthMiddleware()]),

    ///--------------- Ecommerce ---------------///
    GetPage(
        name: '/apps/ecommerce/products',
        page: () => ProductPage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/apps/ecommerce/add_product',
        page: () => AddProduct(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/apps/ecommerce/product-detail',
        page: () => ProductDetail(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/apps/ecommerce/customers',
        page: () => Customers(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/apps/ecommerce/invoice',
        page: () => InvoicePage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/timeline',
        page: () => TimeLinePage(),
        middlewares: [AuthMiddleware()]),

    ///---------------- File ----------------///

    GetPage(
        name: '/apps/files',
        page: () => FileManager(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/apps/file-uploader',
        page: () => FileUploader(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Ntf ----------------///

    GetPage(
        name: '/NFTDashboard',
        page: () => NFTDashboardScreen(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/calender',
        page: () => Calender(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/shopping-customer',
        page: () => ShoppingCustomerScreen(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/fitness',
        page: () => FitnessScreen(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/mila_box',
        page: () => MailBoxScreen(),
        middlewares: [AuthMiddleware()]),

    ///---------------- KanBan ----------------///

    GetPage(
        name: '/kanban',
        page: () => KanBanPage(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Projects ----------------///
    GetPage(
        name: '/projects/project-list',
        page: () => ProjectListPage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/projects/project-detail',
        page: () => ProjectDetail(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/projects/create-project',
        page: () => CreateProject(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Contacts ----------------///

    GetPage(
        name: '/contacts/profile',
        page: () => ProfilePage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/contacts/members',
        page: () => MemberList(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/contacts/edit-profile',
        page: () => EditProfile(),
        middlewares: [AuthMiddleware()]),

    ///---------------- CRM ----------------///

    GetPage(
        name: '/crm/contacts',
        page: () => ContactsPage(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/crm/opportunities',
        page: () => OpportunitiesPage(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Auth ----------------///

    GetPage(name: '/auth/login', page: () => LoginPage()),
    GetPage(name: '/auth/login1', page: () => Login2()),
    GetPage(name: '/auth/forgot_password', page: () => ForgotPassword()),
    GetPage(name: '/auth/forgot_password1', page: () => ForgotPassword2()),
    GetPage(name: '/auth/register', page: () => Register()),
    GetPage(name: '/auth/register1', page: () => Register2()),
    GetPage(name: '/auth/reset_password', page: () => ResetPassword()),
    GetPage(name: '/auth/reset_password1', page: () => ResetPassword2()),
    GetPage(
        name: '/auth/locked',
        page: () => LockedPage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/auth/locked1',
        page: () => LockedPage2(),
        middlewares: [AuthMiddleware()]),

    ///---------------- UI ----------------///

    GetPage(
        name: '/ui/buttons',
        page: () => ButtonsPage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/ui/cards',
        page: () => CardsPage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/ui/tabs',
        page: () => TabsPage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/ui/dialogs',
        page: () => Dialogs(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/ui/carousels',
        page: () => Carousels(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/ui/drag-drop',
        page: () => DragDropPage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/ui/notification',
        page: () => Notifications(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/ui/reviews',
        page: () => ReviewsPage(),
        middlewares: [AuthMiddleware()]),
    // GetPage(
    //     name: '/ui/discover',
    //     page: () =>  DiscoverJobs(),
    //     middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/ui/landing',
        page: () => LandingPage(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Error ----------------///

    GetPage(
        name: '/coming-soon',
        page: () => ComingSoonPage(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/error-404',
        page: () => Error404(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/error-500',
        page: () => Error500(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/maintenance',
        page: () => MaintenancePage(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Chat ----------------///

    GetPage(
        name: '/chat', page: () => ChatPage(), middlewares: [AuthMiddleware()]),

    ///---------------- Form ----------------///

    GetPage(
        name: '/form/basic',
        page: () => BasicPage(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/form/validation',
        page: () => ValidationPage(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/form/quill-editor',
        page: () => QuillEditorScreen(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/form/form-mask',
        page: () => FormMaskPage(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/form/wizard',
        page: () => Wizard(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Other ----------------///

    GetPage(
        name: '/other/basic_tables',
        page: () => BasicTable(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/other/syncfusion_charts',
        page: () => SyncFusionChart(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/other/fl_chart',
        page: () => FlChartScreen(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Maps ----------------///

    GetPage(
        name: '/maps/sf-maps',
        page: () => SfMapPage(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/maps/google-maps',
        page: () => GoogleMapPage(),
        middlewares: [AuthMiddleware()]),
  ];
  return routes
      .map(
        (e) => GetPage(
            name: e.name,
            page: e.page,
            middlewares: e.middlewares,
            transition: Transition.noTransition),
      )
      .toList();
}
