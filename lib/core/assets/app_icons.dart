/// Custom SVG icon paths for the application
///
/// This class provides paths to all custom SVG icons used in the app.
/// Icons should be placed in assets/icons/ directory.
///
/// Usage:
/// ```dart
/// SvgPicture.asset(
///   AppIcons.dashboard,
///   width: 24,
///   height: 24,
///   colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
/// )
/// ```
class AppIcons {
  AppIcons._(); // Private constructor to prevent instantiation

  static const String _basePath = 'assets/icons';

  // Navigation Icons
  static const String dashboard = '$_basePath/dashboard.svg';
  static const String dashboardOutlined = '$_basePath/dashboard_outlined.svg';
  static const String explore = '$_basePath/explore.svg';
  static const String exploreOutlined = '$_basePath/explore_outlined.svg';
  static const String work = '$_basePath/work.svg';
  static const String workOutline = '$_basePath/work_outline.svg';
  static const String map = '$_basePath/map.svg';
  static const String mapOutlined = '$_basePath/map_outlined.svg';
  static const String psychology = '$_basePath/psychology.svg';
  static const String psychologyOutlined = '$_basePath/psychology_outlined.svg';
  static const String settings = '$_basePath/settings.svg';
  static const String settingsOutlined = '$_basePath/settings_outlined.svg';

  // Settings Icons
  static const String person = '$_basePath/person.svg';
  static const String personOutline = '$_basePath/person_outline.svg';
  static const String email = '$_basePath/email.svg';
  static const String emailOutlined = '$_basePath/email_outlined.svg';
  static const String language = '$_basePath/language.svg';
  static const String brightness6 = '$_basePath/brightness_6.svg';
  static const String notifications = '$_basePath/notifications.svg';
  static const String privacyTip = '$_basePath/privacy_tip.svg';
  static const String description = '$_basePath/description.svg';
  static const String info = '$_basePath/info.svg';
  static const String infoOutline = '$_basePath/info_outline.svg';
  static const String feedback = '$_basePath/feedback.svg';
  static const String bugReport = '$_basePath/bug_report.svg';
  static const String arrowForwardIos = '$_basePath/arrow_forward_ios.svg';

  // Dashboard & Discovery Icons
  static const String localFireDepartment = '$_basePath/local_fire_department.svg';
  static const String schedule = '$_basePath/schedule.svg';
  static const String verified = '$_basePath/verified.svg';
  static const String trendingUp = '$_basePath/trending_up.svg';
  static const String quiz = '$_basePath/quiz.svg';
  static const String quizOutlined = '$_basePath/quiz_outlined.svg';
  static const String games = '$_basePath/games.svg';
  static const String gamesOutlined = '$_basePath/games_outlined.svg';
  static const String emojiEvents = '$_basePath/emoji_events.svg';
  static const String emojiEventsOutlined = '$_basePath/emoji_events_outlined.svg';

  // Career Icons
  static const String accountTree = '$_basePath/account_tree.svg';
  static const String search = '$_basePath/search.svg';
  static const String searchOff = '$_basePath/search_off.svg';
  static const String star = '$_basePath/star.svg';
  static const String starOutline = '$_basePath/star_outline.svg';
  static const String category = '$_basePath/category.svg';

  // Game & Assessment Icons
  static const String timer = '$_basePath/timer.svg';
  static const String touchApp = '$_basePath/touch_app.svg';
  static const String checkCircle = '$_basePath/check_circle.svg';
  static const String checkCircleOutline = '$_basePath/check_circle_outline.svg';
  static const String playArrow = '$_basePath/play_arrow.svg';
  static const String pause = '$_basePath/pause.svg';
  static const String pauseCircle = '$_basePath/pause_circle.svg';
  static const String refresh = '$_basePath/refresh.svg';
  static const String sportsEsports = '$_basePath/sports_esports.svg';

  // AI Insights Icons
  static const String autoAwesome = '$_basePath/auto_awesome.svg';
  static const String lightbulbOutline = '$_basePath/lightbulb_outline.svg';
  static const String rocketLaunch = '$_basePath/rocket_launch.svg';
  static const String favorite = '$_basePath/favorite.svg';
  static const String favoriteOutline = '$_basePath/favorite_outline.svg';
  static const String analytics = '$_basePath/analytics.svg';
  static const String dataUsage = '$_basePath/data_usage.svg';

  // School/Admin Icons
  static const String school = '$_basePath/school.svg';
  static const String schoolOutlined = '$_basePath/school_outlined.svg';
  static const String people = '$_basePath/people.svg';
  static const String insertChart = '$_basePath/insert_chart.svg';
  static const String radar = '$_basePath/radar.svg';

  // UI Control Icons
  static const String helpOutline = '$_basePath/help_outline.svg';
  static const String close = '$_basePath/close.svg';
  static const String clear = '$_basePath/clear.svg';
  static const String check = '$_basePath/check.svg';
  static const String arrowBack = '$_basePath/arrow_back.svg';
  static const String arrowForward = '$_basePath/arrow_forward.svg';
  static const String chevronRight = '$_basePath/chevron_right.svg';
  static const String expandMore = '$_basePath/expand_more.svg';
  static const String expandLess = '$_basePath/expand_less.svg';
  static const String unfoldMore = '$_basePath/unfold_more.svg';
  static const String unfoldLess = '$_basePath/unfold_less.svg';

  // Status Icons
  static const String errorOutline = '$_basePath/error_outline.svg';
  static const String cancelOutlined = '$_basePath/cancel_outlined.svg';
  static const String removeCircleOutline = '$_basePath/remove_circle_outline.svg';
  static const String imageNotSupported = '$_basePath/image_not_supported.svg';
  static const String constructionOutlined = '$_basePath/construction_outlined.svg';

  // Authentication Icons
  static const String lock = '$_basePath/lock.svg';
  static const String lockOutline = '$_basePath/lock_outline.svg';
  static const String logout = '$_basePath/logout.svg';
  static const String visibilityOutlined = '$_basePath/visibility_outlined.svg';
  static const String visibilityOffOutlined = '$_basePath/visibility_off_outlined.svg';
  static const String accountCircle = '$_basePath/account_circle.svg';

  // Miscellaneous Icons
  static const String link = '$_basePath/link.svg';
  static const String list = '$_basePath/list.svg';
  static const String history = '$_basePath/history.svg';
  static const String thumbUp = '$_basePath/thumb_up.svg';
  static const String questionMark = '$_basePath/question_mark.svg';
  static const String accessTime = '$_basePath/access_time.svg';
  static const String gMobiledata = '$_basePath/g_mobiledata.svg';
}
