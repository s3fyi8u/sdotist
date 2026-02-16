import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['en']?[key] ?? 
           key;
  }

  bool get isRtl => locale.languageCode == 'ar';
  
  IconData get forwardIcon => isRtl ? Icons.arrow_back_ios : Icons.arrow_forward_ios;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': _en,
    'ar': _ar,
    'tr': _tr,
  };

  // ─── English ───────────────────────────────────────────────
  static const Map<String, String> _en = {
    // General
    'app_name': 'sdotist',
    'get_started': 'Get Started',
    'welcome_home_title': 'Home',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'save': 'Save',
    'edit': 'Edit',
    'add': 'Add',
    'confirm': 'Confirm',
    'required': 'Required',
    'no_data': 'No data available',
    'retry': 'Try Again',
    'close': 'Close',
    'search': 'Search',
    'version': 'Version',

    // Auth - Login
    'welcome_back': 'Welcome Back!',
    'sign_in_continue': 'Please sign in to continue',
    'email': 'Email',
    'enter_email': 'Enter your email',
    'enter_email_validation': 'Enter email',
    'password': 'Password',
    'enter_password': 'Enter your password',
    'enter_password_validation': 'Enter password',
    'login': 'Login',
    'no_account': "Don't have an account?",
    'create_account': 'Create Account',

    // Auth - Register
    'create_new_account': 'Create Account',
    'join_community': 'Join our community today',
    'full_name': 'Full Name',
    'enter_full_name': 'Enter your full name',
    'name_required': 'Name is required',
    'confirm_password': 'Confirm Password',
    'confirm_your_password': 'Confirm your password',
    'email_required': 'Email is required',
    'invalid_email': 'Enter a valid email',
    'password_min_length': 'Must be at least 8 characters',
    'passwords_not_match': 'Passwords do not match',
    'date_of_birth': 'Date of Birth',
    'select_date': 'Select Date',
    'university': 'University',
    'select_university': 'Select University',
    'degree': 'Degree',
    'select_degree': 'Select Degree',
    'specialization': 'Specialization',
    'enter_specialization': 'Enter your specialization',
    'academic_year': 'Academic Year',
    'select_academic_year': 'Select Academic Year',
    'register': 'Register',
    'already_have_account': 'Already have an account?',
    'sign_in': 'Sign In',
    'registration_successful': 'Registration successful! Please login.',
    'registration_failed': 'Registration failed',

    // Degree options
    'degree_bachelor': "Bachelor's",
    'degree_master': "Master's",
    'degree_phd': 'PhD',
    'degree_diploma': 'Diploma',

    // Academic year options
    'year_prep': 'Preparatory',
    'year_1': '1st Year',
    'year_2': '2nd Year',
    'year_3': '3rd Year',
    'year_4': '4th Year',
    'year_5': '5th Year',
    'year_6': '6th Year',
    'year_graduate': 'Graduate',

    // Home
    'welcome_home': 'Welcome Home! 🏠',
    'executive_offices': 'Executive Offices',
    'university_representatives': 'University Representatives',

    // News
    'news': 'News',
    'no_news': 'No news available.',
    'read_more': 'Read More',
    'news_title': 'News',

    // Profile
    'profile': 'Profile',
    'not_logged_in': 'You are not logged in',
    'login_or_create': 'Login or create an account to view your profile',
    'failed_load_profile': 'Failed to load profile',
    'personal_information': 'Personal Information',
    'settings': 'Settings',
    'admin_dashboard': 'Admin Dashboard',
    'logout': 'Logout',
    'profile_image_updated': 'Profile image updated successfully!',
    'error_updating_image': 'Error updating image',

    // User Info
    'user_information': 'User Information',
    'name': 'Name',

    // Settings
    'dark_mode': 'Dark Mode',
    'notifications': 'Notifications',
    'change_password': 'Change Password',
    'terms_and_conditions': 'Terms and Conditions',
    'privacy_policy': 'Privacy Policy',
    'language': 'Language',
    'select_language': 'Select Language',

    // Change Password
    'current_password': 'Current Password',
    'enter_current_password': 'Enter current password',
    'new_password': 'New Password',
    'enter_new_password': 'Enter new password',
    'confirm_new_password': 'Confirm New Password',
    'reenter_new_password': 'Re-enter new password',
    'password_min_8': 'Must be at least 8 chars',
    'new_passwords_not_match': 'New passwords do not match',
    'password_changed': 'Password changed successfully',
    'password_change_failed': 'Failed to change password',

    // Notifications
    'no_notifications': 'No notifications yet',
    'login_required': 'Login Required',
    'login_to_view_notifications': 'Please sign in to view your notifications\nand stay updated.',
    'login_now': 'Login Now',
    'notification_sent': 'Notification sent successfully! 🚀',
    'error_sending_notification': 'Error sending notification',

    // Create / Send Notification
    'send_notification': 'Send Notification',
    'title': 'Title',
    'notification_title': 'Notification Title',
    'please_enter_title': 'Please enter a title',
    'message_body': 'Message Body',
    'enter_message': 'Enter your message',
    'message': 'Message',
    'notification_body': 'Notification Body',
    'notification_body_hint': 'Notification Body',
    'notification_title_hint': 'Notification Title',
    'please_enter_message': 'Please enter a message',
    'send_broadcast': 'Send Broadcast',
    'title_required': 'Title is required',
    'message_required': 'Message is required',
    'notification_sent_success': 'Notification sent successfully',

    // Offices
    'office_details': 'Office Details',
    'office_manager': 'Office Manager',
    'office_members': 'Office Members',
    'no_offices': 'No offices found.',
    'office_not_found': 'Office not found',
    'could_not_launch': 'Could not launch',

    // Representatives
    'no_representatives': 'No representatives currently',

    // Admin Dashboard
    'management': 'Management',
    'users': 'Users',
    'offices': 'Offices',
    'representatives': 'Representatives',

    // Manage Users
    'manage_users': 'Manage Users',
    'confirm_delete': 'Confirm Delete',
    'delete_user_confirm': 'Are you sure you want to delete this user?',
    'user_deleted': 'User deleted successfully',
    'error_deleting_user': 'Error deleting user',
    'error_loading_users': 'Error loading users',
    'edit_user': 'Edit User',
    'role': 'Role',
    'user': 'User',
    'admin': 'Admin',
    'user_role_updated': 'User role updated successfully',
    'error_updating_user': 'Error updating user',
    'no_name': 'No Name',
    'no_email': 'No Email',

    // Manage News
    'manage_news': 'Manage News',
    'add_news': 'Add News',
    'edit_news': 'Edit News',
    'delete_news_confirm': 'Are you sure you want to delete this news item?',
    'news_deleted': 'News deleted successfully',
    'error_deleting_news': 'Error deleting news',
    'error_loading_news': 'Error loading news',
    'news_title_label': 'Title',
    'news_title_hint': 'News Title',
    'news_description': 'Description',
    'news_description_hint': 'Brief description',
    'news_body': 'Body',
    'news_body_hint': 'Full news article body',
    'title_min_5': 'Title must be at least 5 characters',
    'body_required': 'Body is required',
    'news_added': 'News added successfully',
    'news_updated': 'News updated successfully',
    'error_saving_news': 'Error saving news',
    'recommended_dimensions': 'Recommended: 1280×720 (16:9)',
    'add_images': 'Add Images',

    // Manage Offices
    'manage_offices': 'Manage Offices',
    'add_office': 'Add Office',
    'edit_office': 'Edit Office',
    'delete_office_confirm': 'Are you sure you want to delete this office?',
    'office_deleted': 'Office deleted successfully',
    'error_deleting_office': 'Error deleting office',
    'error_loading_offices': 'Error loading offices',
    'office_name': 'Office Name',
    'description': 'Description',
    'office_added': 'Office added successfully',
    'office_updated': 'Office updated successfully',
    'error_saving_office': 'Error saving office',
    'no_description': 'No Description',
    'members': 'Members',
    'create_office': 'Create Office',
    'update_office': 'Update Office',

    // Manage Members
    'manage_members': 'Manage Members',
    'add_member': 'Add Member',
    'edit_member': 'Edit Member',
    'no_members': 'No members yet',
    'delete_member_confirm': 'Are you sure you want to delete this member?',
    'member_deleted': 'Member deleted successfully',
    'error_deleting_member': 'Error deleting member',
    'member_name': 'Member Name',
    'position': 'Position',
    'position_hint': 'e.g. President, Secretary',
    'email_address': 'Email Address',
    'phone': 'Phone',
    'phone_number': 'Phone Number',
    'member_role': 'Role',
    'member': 'Member',
    'head': 'Head',
    'member_added': 'Member added successfully',
    'member_updated': 'Member updated successfully',
    'error_saving_member': 'Error saving member',
    'update_member': 'Update Member',

    // Manage Representatives
    'manage_representatives': 'Manage Representatives',
    'add_representative': 'Add Representative',
    'edit_representative': 'Edit Representative',
    'delete_rep_confirm': 'Are you sure you want to delete this representative?',
    'rep_deleted': 'Representative deleted successfully',
    'error_deleting_rep': 'Error deleting representative',
    'error_loading_reps': 'Error loading representatives',
    'rep_name': 'Representative Name',
    'select_university_required': 'Please select a university',
    'rep_added': 'Representative added successfully',
    'rep_updated': 'Representative updated successfully',
    'error_saving_rep': 'Error saving representative',
    'update_representative': 'Update Representative',
    'no_university': 'No University',

    // Error Screen
    'try_again': 'Try Again',

    // Privacy Policy
    'privacy_policy_title': 'Privacy Policy',
    'privacy_last_updated': 'Last updated: February 13, 2026',
    'privacy_section_1_title': '1. Introduction',
    'privacy_section_1_body': 'Welcome to our application. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you as to how we look after your personal data when you visit our application and tell you about your privacy rights and how the law protects you.',
    'privacy_section_2_title': '2. Data We Collect',
    'privacy_section_2_body': 'We may collect, use, store and transfer different kinds of personal data about you which we have grouped together follows: Identity Data, Contact Data, Technical Data, and Usage Data.',
    'privacy_section_3_title': '3. How We Use Your Data',
    'privacy_section_3_body': 'We will only use your personal data when the law allows us to. Most commonly, we will use your personal data in the following circumstances: Where we need to perform the contract we are about to enter into or have entered into with you.',
    'privacy_section_4_title': '4. Contact Us',
    'privacy_section_4_body': 'If you have any questions about this privacy policy or our privacy practices, please contact us.',

    // Terms and Conditions
    'terms_title': 'Terms and Conditions',
    'terms_last_updated': 'Last updated: February 13, 2026',
    'terms_section_1_title': '1. Introduction',
    'terms_section_1_body': 'These Website Standard Terms and Conditions written on this webpage shall manage your use of our website. These Terms will be applied fully and affect to your use of this App.',
    'terms_section_2_title': '2. Intellectual Property Rights',
    'terms_section_2_body': 'Other than the content you own, under these Terms, we own all the intellectual property rights and materials contained in this App.',
    'terms_section_3_title': '3. Restrictions',
    'terms_section_3_body': 'You are specifically restricted from all of the following: publishing any App material in any other media; selling, sublicensing and/or otherwise commercializing any App material.',
    'terms_section_4_title': '4. Limitation of liability',
    'terms_section_4_body': 'In no event shall we, nor any of our officers, directors and employees, shall be held liable for anything arising out of or in any way connected with your use of this App.',

    // Document Verification
    'upload_student_id': 'Student ID Document',
    'registration_under_review': 'Your registration is under review. You will be notified when your account is activated.',
    'account_activated': 'Your account has been activated',
    'account_rejected': 'Your account has been rejected',
    'pending_registrations': 'Pending Registrations',
    'approve': 'Approve',
    'reject': 'Reject',
    'no_document': 'No document',
    'view_document': 'View Document',
    'confirm_approve': 'Confirm Approval',
    'confirm_reject': 'Confirm Rejection',
    'approve_user_confirm': 'Are you sure you want to approve this user?',
    'reject_user_confirm': 'Are you sure you want to reject this user? This will delete the account.',
    'user_approved': 'User approved successfully',
    'user_rejected': 'User rejected successfully',
    'select_document': 'Select Document',
    'document_selected': 'Document selected',
    'document_required': 'You must upload a student ID document',
    'file_too_large': 'File too large. Maximum size: 5MB',
    'invalid_file_type': 'Invalid file type',
    'account_pending': 'Your account is under review',
  };

  // ─── Arabic ────────────────────────────────────────────────
  static const Map<String, String> _ar = {
    // General
    'app_name': 'sdotist',
    'get_started': 'ابدأ الآن',
    'welcome_home_title': 'الرئيسية',
    'loading': 'جارٍ التحميل...',
    'error': 'خطأ',
    'success': 'نجاح',
    'cancel': 'إلغاء',
    'delete': 'حذف',
    'save': 'حفظ',
    'edit': 'تعديل',
    'add': 'إضافة',
    'confirm': 'تأكيد',
    'required': 'مطلوب',
    'no_data': 'لا توجد بيانات',
    'retry': 'حاول مرة أخرى',
    'close': 'إغلاق',
    'search': 'بحث',
    'version': 'الإصدار',

    // Auth - Login
    'welcome_back': 'مرحباً بعودتك!',
    'sign_in_continue': 'يرجى تسجيل الدخول للمتابعة',
    'email': 'البريد الإلكتروني',
    'enter_email': 'أدخل بريدك الإلكتروني',
    'enter_email_validation': 'أدخل البريد الإلكتروني',
    'password': 'كلمة المرور',
    'enter_password': 'أدخل كلمة المرور',
    'enter_password_validation': 'أدخل كلمة المرور',
    'login': 'تسجيل الدخول',
    'no_account': 'ليس لديك حساب؟',
    'create_account': 'إنشاء حساب',

    // Auth - Register
    'create_new_account': 'إنشاء حساب',
    'join_community': 'انضم إلى مجتمعنا اليوم',
    'full_name': 'الاسم الكامل',
    'enter_full_name': 'أدخل اسمك الكامل',
    'name_required': 'الاسم مطلوب',
    'confirm_password': 'تأكيد كلمة المرور',
    'confirm_your_password': 'أكد كلمة المرور',
    'email_required': 'البريد الإلكتروني مطلوب',
    'invalid_email': 'أدخل بريداً إلكترونياً صالحاً',
    'password_min_length': 'يجب أن تكون 8 أحرف على الأقل',
    'passwords_not_match': 'كلمات المرور غير متطابقة',
    'date_of_birth': 'تاريخ الميلاد',
    'select_date': 'اختر التاريخ',
    'university': 'الجامعة',
    'select_university': 'اختر الجامعة',
    'degree': 'الدرجة العلمية',
    'select_degree': 'اختر الدرجة',
    'specialization': 'التخصص',
    'enter_specialization': 'أدخل تخصصك',
    'academic_year': 'السنة الدراسية',
    'select_academic_year': 'اختر السنة الدراسية',
    'register': 'التسجيل',
    'already_have_account': 'لديك حساب بالفعل؟',
    'sign_in': 'تسجيل الدخول',
    'registration_successful': 'تم التسجيل بنجاح! يرجى تسجيل الدخول.',
    'registration_failed': 'فشل التسجيل',

    // Degree options
    'degree_bachelor': 'بكالوريوس',
    'degree_master': 'ماجستير',
    'degree_phd': 'دكتوراه',
    'degree_diploma': 'دبلوم',

    // Academic year options
    'year_prep': 'تحضيري',
    'year_1': 'السنة الأولى',
    'year_2': 'السنة الثانية',
    'year_3': 'السنة الثالثة',
    'year_4': 'السنة الرابعة',
    'year_5': 'السنة الخامسة',
    'year_6': 'السنة السادسة',
    'year_graduate': 'خريج',

    // Home
    'welcome_home': 'مرحباً بك في الصفحة الرئيسية! 🏠',
    'executive_offices': 'المكاتب التنفيذية',
    'university_representatives': 'ممثلي الجامعات',

    // News
    'news': 'الأخبار',
    'no_news': 'لا توجد أخبار متاحة.',
    'read_more': 'اقرأ المزيد',
    'news_title': 'الأخبار',

    // Profile
    'profile': 'الملف الشخصي',
    'not_logged_in': 'لم تقم بتسجيل الدخول',
    'login_or_create': 'سجل دخولك أو أنشئ حساباً لعرض ملفك الشخصي',
    'failed_load_profile': 'فشل في تحميل الملف الشخصي',
    'personal_information': 'المعلومات الشخصية',
    'settings': 'الإعدادات',
    'admin_dashboard': 'لوحة التحكم',
    'logout': 'تسجيل الخروج',
    'profile_image_updated': 'تم تحديث صورة الملف الشخصي بنجاح!',
    'error_updating_image': 'خطأ في تحديث الصورة',

    // User Info
    'user_information': 'معلومات المستخدم',
    'name': 'الاسم',

    // Settings
    'dark_mode': 'الوضع الداكن',
    'notifications': 'الإشعارات',
    'change_password': 'تغيير كلمة المرور',
    'terms_and_conditions': 'الشروط والأحكام',
    'privacy_policy': 'سياسة الخصوصية',
    'language': 'اللغة',
    'select_language': 'اختر اللغة',

    // Change Password
    'current_password': 'كلمة المرور الحالية',
    'enter_current_password': 'أدخل كلمة المرور الحالية',
    'new_password': 'كلمة المرور الجديدة',
    'enter_new_password': 'أدخل كلمة المرور الجديدة',
    'confirm_new_password': 'تأكيد كلمة المرور الجديدة',
    'reenter_new_password': 'أعد إدخال كلمة المرور الجديدة',
    'password_min_8': 'يجب أن تكون 8 أحرف على الأقل',
    'new_passwords_not_match': 'كلمات المرور الجديدة غير متطابقة',
    'password_changed': 'تم تغيير كلمة المرور بنجاح',
    'password_change_failed': 'فشل في تغيير كلمة المرور',

    // Notifications
    'no_notifications': 'لا توجد إشعارات بعد',
    'login_required': 'تسجيل الدخول مطلوب',
    'login_to_view_notifications': 'يرجى تسجيل الدخول لعرض إشعاراتك\nوالبقاء على اطلاع.',
    'login_now': 'تسجيل الدخول الآن',
    'notification_sent': 'تم إرسال الإشعار بنجاح! 🚀',
    'error_sending_notification': 'خطأ في إرسال الإشعار',

    // Create / Send Notification
    'send_notification': 'إرسال إشعار',
    'title': 'العنوان',
    'notification_title': 'عنوان الإشعار',
    'please_enter_title': 'يرجى إدخال العنوان',
    'message_body': 'نص الرسالة',
    'enter_message': 'أدخل رسالتك',
    'message': 'الرسالة',
    'notification_body': 'نص الإشعار',
    'notification_body_hint': 'نص الإشعار',
    'notification_title_hint': 'عنوان الإشعار',
    'please_enter_message': 'يرجى إدخال الرسالة',
    'send_broadcast': 'إرسال بث',
    'title_required': 'العنوان مطلوب',
    'message_required': 'الرسالة مطلوبة',
    'notification_sent_success': 'تم إرسال الإشعار بنجاح',

    // Offices
    'office_details': 'تفاصيل المكتب',
    'office_manager': 'مدير المكتب',
    'office_members': 'أعضاء المكتب',
    'no_offices': 'لا توجد مكاتب.',
    'office_not_found': 'المكتب غير موجود',
    'could_not_launch': 'تعذر الفتح',

    // Representatives
    'no_representatives': 'لا يوجد ممثلين حالياً',

    // Admin Dashboard
    'management': 'الإدارة',
    'users': 'المستخدمون',
    'offices': 'المكاتب',
    'representatives': 'الممثلون',

    // Manage Users
    'manage_users': 'إدارة المستخدمين',
    'confirm_delete': 'تأكيد الحذف',
    'delete_user_confirm': 'هل أنت متأكد من حذف هذا المستخدم؟',
    'user_deleted': 'تم حذف المستخدم بنجاح',
    'error_deleting_user': 'خطأ في حذف المستخدم',
    'error_loading_users': 'خطأ في تحميل المستخدمين',
    'edit_user': 'تعديل المستخدم',
    'role': 'الدور',
    'user': 'مستخدم',
    'admin': 'مشرف',
    'user_role_updated': 'تم تحديث دور المستخدم بنجاح',
    'error_updating_user': 'خطأ في تحديث المستخدم',
    'no_name': 'بدون اسم',
    'no_email': 'بدون بريد',

    // Manage News
    'manage_news': 'إدارة الأخبار',
    'add_news': 'إضافة خبر',
    'edit_news': 'تعديل خبر',
    'delete_news_confirm': 'هل أنت متأكد من حذف هذا الخبر؟',
    'news_deleted': 'تم حذف الخبر بنجاح',
    'error_deleting_news': 'خطأ في حذف الخبر',
    'error_loading_news': 'خطأ في تحميل الأخبار',
    'news_title_label': 'العنوان',
    'news_title_hint': 'عنوان الخبر',
    'news_description': 'الوصف',
    'news_description_hint': 'وصف مختصر',
    'news_body': 'النص',
    'news_body_hint': 'نص الخبر الكامل',
    'title_min_5': 'العنوان يجب أن يكون 5 أحرف على الأقل',
    'body_required': 'النص مطلوب',
    'news_added': 'تمت إضافة الخبر بنجاح',
    'news_updated': 'تم تحديث الخبر بنجاح',
    'error_saving_news': 'خطأ في حفظ الخبر',
    'recommended_dimensions': 'مُوصى به: 1280×720 (16:9)',
    'add_images': 'إضافة صور',

    // Manage Offices
    'manage_offices': 'إدارة المكاتب',
    'add_office': 'إضافة مكتب',
    'edit_office': 'تعديل مكتب',
    'delete_office_confirm': 'هل أنت متأكد من حذف هذا المكتب؟',
    'office_deleted': 'تم حذف المكتب بنجاح',
    'error_deleting_office': 'خطأ في حذف المكتب',
    'error_loading_offices': 'خطأ في تحميل المكاتب',
    'office_name': 'اسم المكتب',
    'description': 'الوصف',
    'office_added': 'تمت إضافة المكتب بنجاح',
    'office_updated': 'تم تحديث المكتب بنجاح',
    'error_saving_office': 'خطأ في حفظ المكتب',
    'no_description': 'بدون وصف',
    'members': 'الأعضاء',
    'create_office': 'إنشاء مكتب',
    'update_office': 'تحديث مكتب',

    // Manage Members
    'manage_members': 'إدارة الأعضاء',
    'add_member': 'إضافة عضو',
    'edit_member': 'تعديل عضو',
    'no_members': 'لا يوجد أعضاء بعد',
    'delete_member_confirm': 'هل أنت متأكد من حذف هذا العضو؟',
    'member_deleted': 'تم حذف العضو بنجاح',
    'error_deleting_member': 'خطأ في حذف العضو',
    'member_name': 'اسم العضو',
    'position': 'المنصب',
    'position_hint': 'مثال: رئيس، أمين سر',
    'email_address': 'البريد الإلكتروني',
    'phone': 'الهاتف',
    'phone_number': 'رقم الهاتف',
    'member_role': 'الدور',
    'member': 'عضو',
    'head': 'رئيس',
    'member_added': 'تمت إضافة العضو بنجاح',
    'member_updated': 'تم تحديث العضو بنجاح',
    'error_saving_member': 'خطأ في حفظ العضو',
    'update_member': 'تحديث عضو',

    // Manage Representatives
    'manage_representatives': 'إدارة الممثلين',
    'add_representative': 'إضافة ممثل',
    'edit_representative': 'تعديل ممثل',
    'delete_rep_confirm': 'هل أنت متأكد من حذف هذا الممثل؟',
    'rep_deleted': 'تم حذف الممثل بنجاح',
    'error_deleting_rep': 'خطأ في حذف الممثل',
    'error_loading_reps': 'خطأ في تحميل الممثلين',
    'rep_name': 'اسم الممثل',
    'select_university_required': 'يرجى اختيار الجامعة',
    'rep_added': 'تمت إضافة الممثل بنجاح',
    'rep_updated': 'تم تحديث الممثل بنجاح',
    'error_saving_rep': 'خطأ في حفظ الممثل',
    'update_representative': 'تحديث ممثل',
    'no_university': 'بدون جامعة',

    // Error Screen
    'try_again': 'حاول مرة أخرى',

    // Privacy Policy
    'privacy_policy_title': 'سياسة الخصوصية',
    'privacy_last_updated': 'آخر تحديث: ١٣ فبراير ٢٠٢٦',
    'privacy_section_1_title': '١. مقدمة',
    'privacy_section_1_body': 'مرحباً بك في تطبيقنا. نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. ستُعلمك سياسة الخصوصية هذه بكيفية رعايتنا لبياناتك الشخصية عند زيارتك لتطبيقنا وتُخبرك عن حقوق الخصوصية وكيف يحميك القانون.',
    'privacy_section_2_title': '٢. البيانات التي نجمعها',
    'privacy_section_2_body': 'قد نقوم بجمع واستخدام وتخزين ونقل أنواع مختلفة من البيانات الشخصية عنك والتي جمعناها معاً كالتالي: بيانات الهوية، بيانات الاتصال، البيانات التقنية، وبيانات الاستخدام.',
    'privacy_section_3_title': '٣. كيف نستخدم بياناتك',
    'privacy_section_3_body': 'سنستخدم بياناتك الشخصية فقط عندما يسمح لنا القانون بذلك. في الأغلب، سنستخدم بياناتك الشخصية في الحالات التالية: عندما نحتاج إلى تنفيذ العقد الذي نحن على وشك الدخول فيه أو الذي دخلنا فيه معك.',
    'privacy_section_4_title': '٤. اتصل بنا',
    'privacy_section_4_body': 'إذا كان لديك أي أسئلة حول سياسة الخصوصية أو ممارسات الخصوصية لدينا، يرجى الاتصال بنا.',

    // Terms and Conditions
    'terms_title': 'الشروط والأحكام',
    'terms_last_updated': 'آخر تحديث: ١٣ فبراير ٢٠٢٦',
    'terms_section_1_title': '١. مقدمة',
    'terms_section_1_body': 'تحكم هذه الشروط والأحكام القياسية المكتوبة في هذه الصفحة استخدامك لموقعنا. سيتم تطبيق هذه الشروط بالكامل وتؤثر على استخدامك لهذا التطبيق.',
    'terms_section_2_title': '٢. حقوق الملكية الفكرية',
    'terms_section_2_body': 'بخلاف المحتوى الذي تملكه، بموجب هذه الشروط، نحن نملك جميع حقوق الملكية الفكرية والمواد الموجودة في هذا التطبيق.',
    'terms_section_3_title': '٣. القيود',
    'terms_section_3_body': 'أنت مقيد تحديداً من جميع ما يلي: نشر أي مواد التطبيق في أي وسيلة إعلام أخرى؛ بيع أو ترخيص و/أو تسويق أي مواد التطبيق.',
    'terms_section_4_title': '٤. تحديد المسؤولية',
    'terms_section_4_body': 'لن نكون مسؤولين بأي حال من الأحوال، نحن أو أي من مسؤولينا ومديرينا وموظفينا، عن أي شيء ينشأ عن أو يتصل بأي شكل باستخدامك لهذا التطبيق.',

    // Document Verification
    'upload_student_id': 'وثيقة الهوية الطلابية',
    'registration_under_review': 'تسجيلك قيد المراجعة. سيتم إشعارك عند تفعيل حسابك.',
    'account_activated': 'تم تفعيل حسابك',
    'account_rejected': 'تم رفض حسابك',
    'pending_registrations': 'التسجيلات المعلقة',
    'approve': 'قبول',
    'reject': 'رفض',
    'no_document': 'لا يوجد مستند',
    'view_document': 'عرض المستند',
    'confirm_approve': 'تأكيد القبول',
    'confirm_reject': 'تأكيد الرفض',
    'approve_user_confirm': 'هل أنت متأكد من قبول هذا المستخدم؟',
    'reject_user_confirm': 'هل أنت متأكد من رفض هذا المستخدم؟ سيتم حذف الحساب.',
    'user_approved': 'تم قبول المستخدم بنجاح',
    'user_rejected': 'تم رفض المستخدم بنجاح',
    'select_document': 'اختر مستند',
    'document_selected': 'تم اختيار المستند',
    'document_required': 'يجب رفع وثيقة الهوية الطلابية',
    'file_too_large': 'حجم الملف كبير جداً. الحد الأقصى: 5 ميجابايت',
    'invalid_file_type': 'نوع ملف غير مدعوم',
    'account_pending': 'حسابك قيد المراجعة',
  };

  // ─── Turkish ───────────────────────────────────────────────
  static const Map<String, String> _tr = {
    // General
    'app_name': 'sdotist',
    'get_started': 'Başlayın',
    'welcome_home_title': 'Ana Sayfa',
    'loading': 'Yükleniyor...',
    'error': 'Hata',
    'success': 'Başarılı',
    'cancel': 'İptal',
    'delete': 'Sil',
    'save': 'Kaydet',
    'edit': 'Düzenle',
    'add': 'Ekle',
    'confirm': 'Onayla',
    'required': 'Zorunlu',
    'no_data': 'Veri bulunamadı',
    'retry': 'Tekrar Dene',
    'close': 'Kapat',
    'search': 'Ara',
    'version': 'Sürüm',

    // Auth - Login
    'welcome_back': 'Tekrar Hoş Geldiniz!',
    'sign_in_continue': 'Devam etmek için lütfen giriş yapın',
    'email': 'E-posta',
    'enter_email': 'E-postanızı girin',
    'enter_email_validation': 'E-posta girin',
    'password': 'Şifre',
    'enter_password': 'Şifrenizi girin',
    'enter_password_validation': 'Şifre girin',
    'login': 'Giriş Yap',
    'no_account': 'Hesabınız yok mu?',
    'create_account': 'Hesap Oluştur',

    // Auth - Register
    'create_new_account': 'Hesap Oluştur',
    'join_community': 'Bugün topluluğumuza katılın',
    'full_name': 'Ad Soyad',
    'enter_full_name': 'Adınızı ve soyadınızı girin',
    'name_required': 'Ad gerekli',
    'confirm_password': 'Şifreyi Onayla',
    'confirm_your_password': 'Şifrenizi onaylayın',
    'email_required': 'E-posta gerekli',
    'invalid_email': 'Geçerli bir e-posta girin',
    'password_min_length': 'En az 8 karakter olmalı',
    'passwords_not_match': 'Şifreler eşleşmiyor',
    'date_of_birth': 'Doğum Tarihi',
    'select_date': 'Tarih Seçin',
    'university': 'Üniversite',
    'select_university': 'Üniversite Seçin',
    'degree': 'Derece',
    'select_degree': 'Derece Seçin',
    'specialization': 'Uzmanlık',
    'enter_specialization': 'Uzmanlığınızı girin',
    'academic_year': 'Akademik Yıl',
    'select_academic_year': 'Akademik Yıl Seçin',
    'register': 'Kayıt Ol',
    'already_have_account': 'Zaten hesabınız var mı?',
    'sign_in': 'Giriş Yap',
    'registration_successful': 'Kayıt başarılı! Lütfen giriş yapın.',
    'registration_failed': 'Kayıt başarısız',

    // Degree options
    'degree_bachelor': 'Lisans',
    'degree_master': 'Yüksek Lisans',
    'degree_phd': 'Doktora',
    'degree_diploma': 'Diploma',

    // Academic year options
    'year_prep': 'Hazırlık',
    'year_1': '1. Sınıf',
    'year_2': '2. Sınıf',
    'year_3': '3. Sınıf',
    'year_4': '4. Sınıf',
    'year_5': '5. Sınıf',
    'year_6': '6. Sınıf',
    'year_graduate': 'Mezun',

    // Home
    'welcome_home': 'Ana Sayfaya Hoş Geldiniz! 🏠',
    'executive_offices': 'Yürütme Ofisleri',
    'university_representatives': 'Üniversite Temsilcileri',

    // News
    'news': 'Haberler',
    'no_news': 'Haber bulunamadı.',
    'read_more': 'Devamını Oku',
    'news_title': 'Haberler',

    // Profile
    'profile': 'Profil',
    'not_logged_in': 'Giriş yapmadınız',
    'login_or_create': 'Profilinizi görüntülemek için giriş yapın veya hesap oluşturun',
    'failed_load_profile': 'Profil yüklenemedi',
    'personal_information': 'Kişisel Bilgiler',
    'settings': 'Ayarlar',
    'admin_dashboard': 'Yönetim Paneli',
    'logout': 'Çıkış Yap',
    'profile_image_updated': 'Profil resmi başarıyla güncellendi!',
    'error_updating_image': 'Resim güncellenirken hata oluştu',

    // User Info
    'user_information': 'Kullanıcı Bilgileri',
    'name': 'Ad',

    // Settings
    'dark_mode': 'Karanlık Mod',
    'notifications': 'Bildirimler',
    'change_password': 'Şifre Değiştir',
    'terms_and_conditions': 'Şartlar ve Koşullar',
    'privacy_policy': 'Gizlilik Politikası',
    'language': 'Dil',
    'select_language': 'Dil Seçin',

    // Change Password
    'current_password': 'Mevcut Şifre',
    'enter_current_password': 'Mevcut şifrenizi girin',
    'new_password': 'Yeni Şifre',
    'enter_new_password': 'Yeni şifrenizi girin',
    'confirm_new_password': 'Yeni Şifreyi Onayla',
    'reenter_new_password': 'Yeni şifreyi tekrar girin',
    'password_min_8': 'En az 8 karakter olmalı',
    'new_passwords_not_match': 'Yeni şifreler eşleşmiyor',
    'password_changed': 'Şifre başarıyla değiştirildi',
    'password_change_failed': 'Şifre değiştirilemedi',

    // Notifications
    'no_notifications': 'Henüz bildirim yok',
    'login_required': 'Giriş Gerekli',
    'login_to_view_notifications': 'Bildirimlerinizi görüntülemek için\nlütfen giriş yapın.',
    'login_now': 'Şimdi Giriş Yap',
    'notification_sent': 'Bildirim başarıyla gönderildi! 🚀',
    'error_sending_notification': 'Bildirim gönderilirken hata oluştu',

    // Create / Send Notification
    'send_notification': 'Bildirim Gönder',
    'title': 'Başlık',
    'notification_title': 'Bildirim Başlığı',
    'please_enter_title': 'Lütfen bir başlık girin',
    'message_body': 'Mesaj İçeriği',
    'enter_message': 'Mesajınızı girin',
    'message': 'Mesaj',
    'notification_body': 'Bildirim İçeriği',
    'notification_body_hint': 'Bildirim İçeriği',
    'notification_title_hint': 'Bildirim Başlığı',
    'please_enter_message': 'Lütfen bir mesaj girin',
    'send_broadcast': 'Yayın Gönder',
    'title_required': 'Başlık gerekli',
    'message_required': 'Mesaj gerekli',
    'notification_sent_success': 'Bildirim başarıyla gönderildi',

    // Offices
    'office_details': 'Ofis Detayları',
    'office_manager': 'Ofis Müdürü',
    'office_members': 'Ofis Üyeleri',
    'no_offices': 'Ofis bulunamadı.',
    'office_not_found': 'Ofis bulunamadı',
    'could_not_launch': 'Açılamadı',

    // Representatives
    'no_representatives': 'Şu anda temsilci yok',

    // Admin Dashboard
    'management': 'Yönetim',
    'users': 'Kullanıcılar',
    'offices': 'Ofisler',
    'representatives': 'Temsilciler',

    // Manage Users
    'manage_users': 'Kullanıcı Yönetimi',
    'confirm_delete': 'Silme Onayı',
    'delete_user_confirm': 'Bu kullanıcıyı silmek istediğinizden emin misiniz?',
    'user_deleted': 'Kullanıcı başarıyla silindi',
    'error_deleting_user': 'Kullanıcı silinirken hata oluştu',
    'error_loading_users': 'Kullanıcılar yüklenirken hata oluştu',
    'edit_user': 'Kullanıcı Düzenle',
    'role': 'Rol',
    'user': 'Kullanıcı',
    'admin': 'Yönetici',
    'user_role_updated': 'Kullanıcı rolü başarıyla güncellendi',
    'error_updating_user': 'Kullanıcı güncellenirken hata oluştu',
    'no_name': 'İsimsiz',
    'no_email': 'E-posta yok',

    // Manage News
    'manage_news': 'Haber Yönetimi',
    'add_news': 'Haber Ekle',
    'edit_news': 'Haber Düzenle',
    'delete_news_confirm': 'Bu haberi silmek istediğinizden emin misiniz?',
    'news_deleted': 'Haber başarıyla silindi',
    'error_deleting_news': 'Haber silinirken hata oluştu',
    'error_loading_news': 'Haberler yüklenirken hata oluştu',
    'news_title_label': 'Başlık',
    'news_title_hint': 'Haber Başlığı',
    'news_description': 'Açıklama',
    'news_description_hint': 'Kısa açıklama',
    'news_body': 'İçerik',
    'news_body_hint': 'Tam haber içeriği',
    'title_min_5': 'Başlık en az 5 karakter olmalı',
    'body_required': 'İçerik gerekli',
    'news_added': 'Haber başarıyla eklendi',
    'news_updated': 'Haber başarıyla güncellendi',
    'error_saving_news': 'Haber kaydedilirken hata oluştu',
    'recommended_dimensions': 'Önerilen: 1280×720 (16:9)',
    'add_images': 'Resim Ekle',

    // Manage Offices
    'manage_offices': 'Ofis Yönetimi',
    'add_office': 'Ofis Ekle',
    'edit_office': 'Ofis Düzenle',
    'delete_office_confirm': 'Bu ofisi silmek istediğinizden emin misiniz?',
    'office_deleted': 'Ofis başarıyla silindi',
    'error_deleting_office': 'Ofis silinirken hata oluştu',
    'error_loading_offices': 'Ofisler yüklenirken hata oluştu',
    'office_name': 'Ofis Adı',
    'description': 'Açıklama',
    'office_added': 'Ofis başarıyla eklendi',
    'office_updated': 'Ofis başarıyla güncellendi',
    'error_saving_office': 'Ofis kaydedilirken hata oluştu',
    'no_description': 'Açıklama yok',
    'members': 'Üyeler',
    'create_office': 'Ofis Oluştur',
    'update_office': 'Ofis Güncelle',

    // Manage Members
    'manage_members': 'Üye Yönetimi',
    'add_member': 'Üye Ekle',
    'edit_member': 'Üye Düzenle',
    'no_members': 'Henüz üye yok',
    'delete_member_confirm': 'Bu üyeyi silmek istediğinizden emin misiniz?',
    'member_deleted': 'Üye başarıyla silindi',
    'error_deleting_member': 'Üye silinirken hata oluştu',
    'member_name': 'Üye Adı',
    'position': 'Pozisyon',
    'position_hint': 'örn. Başkan, Sekreter',
    'email_address': 'E-posta Adresi',
    'phone': 'Telefon',
    'phone_number': 'Telefon Numarası',
    'member_role': 'Rol',
    'member': 'Üye',
    'head': 'Başkan',
    'member_added': 'Üye başarıyla eklendi',
    'member_updated': 'Üye başarıyla güncellendi',
    'error_saving_member': 'Üye kaydedilirken hata oluştu',
    'update_member': 'Üye Güncelle',

    // Manage Representatives
    'manage_representatives': 'Temsilci Yönetimi',
    'add_representative': 'Temsilci Ekle',
    'edit_representative': 'Temsilci Düzenle',
    'delete_rep_confirm': 'Bu temsilciyi silmek istediğinizden emin misiniz?',
    'rep_deleted': 'Temsilci başarıyla silindi',
    'error_deleting_rep': 'Temsilci silinirken hata oluştu',
    'error_loading_reps': 'Temsilciler yüklenirken hata oluştu',
    'rep_name': 'Temsilci Adı',
    'select_university_required': 'Lütfen bir üniversite seçin',
    'rep_added': 'Temsilci başarıyla eklendi',
    'rep_updated': 'Temsilci başarıyla güncellendi',
    'error_saving_rep': 'Temsilci kaydedilirken hata oluştu',
    'update_representative': 'Temsilci Güncelle',
    'no_university': 'Üniversite yok',

    // Error Screen
    'try_again': 'Tekrar Dene',

    // Privacy Policy
    'privacy_policy_title': 'Gizlilik Politikası',
    'privacy_last_updated': 'Son güncelleme: 13 Şubat 2026',
    'privacy_section_1_title': '1. Giriş',
    'privacy_section_1_body': 'Uygulamamıza hoş geldiniz. Gizliliğinize saygı duyuyor ve kişisel verilerinizi korumaya kararlıyız. Bu gizlilik politikası, uygulamamızı ziyaret ettiğinizde kişisel verilerinize nasıl baktığımız ve gizlilik haklarınız ile yasanın sizi nasıl koruduğu hakkında sizi bilgilendirecektir.',
    'privacy_section_2_title': '2. Topladığımız Veriler',
    'privacy_section_2_body': 'Hakkınızda farklı türlerde kişisel verileri toplayabilir, kullanabilir, depolayabilir ve aktarabiliriz: Kimlik Verileri, İletişim Verileri, Teknik Veriler ve Kullanım Verileri.',
    'privacy_section_3_title': '3. Verilerinizi Nasıl Kullanıyoruz',
    'privacy_section_3_body': 'Kişisel verilerinizi yalnızca yasanın izin verdiği durumlarda kullanacağız. En yaygın olarak, kişisel verilerinizi şu durumlarda kullanacağız: Sizinle yapmak üzere olduğumuz veya yaptığımız sözleşmeyi yerine getirmemiz gerektiğinde.',
    'privacy_section_4_title': '4. Bize Ulaşın',
    'privacy_section_4_body': 'Bu gizlilik politikası veya gizlilik uygulamalarımız hakkında sorularınız varsa, lütfen bizimle iletişime geçin.',

    // Terms and Conditions
    'terms_title': 'Şartlar ve Koşullar',
    'terms_last_updated': 'Son güncelleme: 13 Şubat 2026',
    'terms_section_1_title': '1. Giriş',
    'terms_section_1_body': 'Bu web sayfasında yazılan Standart Şartlar ve Koşullar, web sitemizi kullanımınızı yönetecektir. Bu Şartlar tamamen uygulanacak ve bu Uygulamayı kullanımınızı etkileyecektir.',
    'terms_section_2_title': '2. Fikri Mülkiyet Hakları',
    'terms_section_2_body': 'Sahip olduğunuz içerik dışında, bu Şartlar kapsamında, bu Uygulamada yer alan tüm fikri mülkiyet hakları ve materyaller bize aittir.',
    'terms_section_3_title': '3. Kısıtlamalar',
    'terms_section_3_body': 'Şunların tümünden özellikle kısıtlanmış bulunmaktasınız: herhangi bir Uygulama materyalini başka bir medyada yayınlamak; herhangi bir Uygulama materyalini satmak, alt lisanslamak ve/veya başka şekilde ticarileştirmek.',
    'terms_section_4_title': '4. Sorumluluk Sınırlaması',
    'terms_section_4_body': 'Hiçbir durumda ne biz, ne de yetkililerimiz, yöneticilerimiz ve çalışanlarımız, bu Uygulamayı kullanımınızdan kaynaklanan veya herhangi bir şekilde bağlantılı olan hiçbir şeyden sorumlu tutulmayacaktır.',

    // Document Verification
    'upload_student_id': 'Öğrenci Kimlik Belgesi',
    'registration_under_review': 'Kaydınız inceleme altında. Hesabınız aktifleştirildiğinde bilgilendirileceksiniz.',
    'account_activated': 'Hesabınız aktifleştirildi',
    'account_rejected': 'Hesabınız reddedildi',
    'pending_registrations': 'Bekleyen Kayıtlar',
    'approve': 'Onayla',
    'reject': 'Reddet',
    'no_document': 'Belge yok',
    'view_document': 'Belgeyi Görüntüle',
    'confirm_approve': 'Onayı Onayla',
    'confirm_reject': 'Reddi Onayla',
    'approve_user_confirm': 'Bu kullanıcıyı onaylamak istediğinizden emin misiniz?',
    'reject_user_confirm': 'Bu kullanıcıyı reddetmek istediğinizden emin misiniz? Hesap silinecektir.',
    'user_approved': 'Kullanıcı başarıyla onaylandı',
    'user_rejected': 'Kullanıcı başarıyla reddedildi',
    'select_document': 'Belge Seçin',
    'document_selected': 'Belge seçildi',
    'document_required': 'Öğrenci kimlik belgesi yüklemeniz gerekiyor',
    'file_too_large': 'Dosya çok büyük. Maksimum boyut: 5MB',
    'invalid_file_type': 'Geçersiz dosya türü',
    'account_pending': 'Hesabınız inceleniyor',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
