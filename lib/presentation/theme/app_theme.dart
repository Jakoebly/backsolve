import 'package:flutter/material.dart';

/// THE single theme file (Constitution IV). Every value was sampled from
/// `docs/mockups_screens/*.png` — a 360 × 800 dp frame rendered at 1.2× —
/// and is documented in `specs/001-home-practice-setup/contracts/theme-tokens.md`.
/// Screens and widgets reference these tokens only; none of them may spell
/// out a `Color(0x…)`, a numeric `fontSize`, or a literal `EdgeInsets`.

/// Colors (theme-tokens.md §1). Exact sampled hex values.
abstract final class AppColors {
  /// The teal primary: quick start card, W8 bar, legend square, selected
  /// radio and card border, Start button.
  static const Color primary = Color(0xFF007B82);

  /// Text and icons on teal.
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// White at 85 % opacity: "60 seconds · adaptive · L4" on the teal card.
  static const Color onPrimarySubtle = Color(0xD9FFFFFF);

  /// Settings chip on a teal card (= white 20 % over primary).
  static const Color onPrimaryChip = Color(0xFF33959B);

  /// Play circle on a teal card (= white 22 % over primary).
  static const Color onPrimaryCircle = Color(0xFF38989D);

  /// Screen background; also the Level/time badge fill.
  static const Color background = Color(0xFFF7F8FA);

  /// Cards, nav bar, selected segment.
  static const Color surface = Color(0xFFFFFFFF);

  /// Chip on a white card, custom-session icon circle, play circle on white.
  static const Color surfaceMuted = Color(0xFFF2F4F7);

  /// Difficulty and Answers control track.
  static const Color segmentTrack = Color(0xFFEEF0F4);

  /// Active bottom-nav pill.
  static const Color navActivePill = Color(0xFFE8EAEE);

  /// 1 dp card borders, chart grid lines, sessions divider.
  static const Color border = Color(0xFFE3E6EC);

  /// Unselected radio ring (2 dp).
  static const Color radioRing = Color(0xFFB6BCC7);

  /// Session Setup back button fill (= primary 12 % over background).
  static const Color backButton = Color(0xFFD9E9EC);

  /// W1–W7 accuracy bars.
  static const Color barMuted = Color(0xFFCFE0E6);

  /// Titles, stat values, speed dots, legend dot, selected segment text,
  /// chip text on white.
  static const Color ink = Color(0xFF14171C);

  /// Section labels, tagline, subtitles, helper text, week labels.
  static const Color textSecondary = Color(0xFF6B7280);

  /// Unselected segment labels.
  static const Color textSegment = Color(0xFF4F5561);

  /// Inactive nav icon + label, chevrons, "days streak" labels.
  static const Color navInactive = Color(0xFF5D636E);

  /// Active nav icon (the active label uses [ink]).
  static const Color navActiveIcon = Color(0xFF3F4653);

  /// 1–2 dp halo around the chart's speed dots.
  static const Color speedDotRing = Color(0xFFFFFFFF);

  /// [primary] at 40 % opacity — derived, the mockups show no disabled
  /// state; used only by the disabled Start button (FR-020).
  static const Color primaryDisabled = Color(0x66007B82);
}

/// Spacing scale in dp (theme-tokens.md §2).
abstract final class AppSpacing {
  /// Value ↔ delta gap in tiles, badge inner gap.
  static const double xxs = 4;

  /// Session-type card gap, badge row gap, chart bar gap.
  static const double xs = 8;

  /// Stacked card gap, grid gap, section label → content, helper top margin.
  static const double sm = 12;

  /// Card inner padding, header icon → title gap.
  static const double md = 16;

  /// Screen horizontal padding, top padding under the safe area.
  static const double lg = 20;

  /// Content → next section label.
  static const double xl = 24;

  /// Bottom padding above the Start button / nav bar.
  static const double xxl = 32;

  /// Horizontal padding inside a settings chip.
  static const double chipHorizontal = 10;
}

/// Element sizes in dp (theme-tokens.md §3).
abstract final class AppSizes {
  static const double appIcon = 52;
  static const double appIconRadius = 14;

  /// White glyph inside the app icon (home.png: ≈ 36 px → 30 dp).
  static const double appIconGlyph = 30;

  /// Home quick start play circle.
  static const double playCircleLg = 48;

  /// Practice quick start play circle.
  static const double playCircleSm = 36;

  /// Play glyph inside [playCircleLg] (triangle ≈ 20 px tall in home.png).
  static const double playIconLg = 28;

  /// Play glyph inside [playCircleSm] (triangle ≈ 15 px tall in practice.png).
  static const double playIconSm = 20;
  static const double customIconCircle = 32;
  static const double backButton = 32;
  static const double radio = 18;
  static const double radioRing = 2;
  static const double segmentHeight = 48;
  static const double segmentInnerPadding = 4;
  static const double startButtonHeight = 53;
  static const double navBarHeight = 58;
  static const double navPillWidth = 106;
  static const double navPillHeight = 48;
  static const double chipHeight = 24;
  static const double badgeHeight = 20;
  static const double chartBarWidth = 30;

  /// First grid line → bar base.
  static const double chartPlotHeight = 168;

  /// Grid line pitch.
  static const double chartGridStep = 42;
  static const double speedDot = 8;
  static const double speedDotRing = 2;
  static const double legendSwatch = 8;

  /// Level/time badge glyphs.
  static const double iconXs = 12;

  /// Settings chip tune glyph.
  static const double iconChip = 14;

  /// Bolt / shuffle / target / checklist glyphs.
  static const double iconSm = 16;
  static const double iconNav = 22;
  static const double cardBorderWidth = 1;
  static const double selectedCardBorderWidth = 2;

  /// The Custom session row's dashed outline (practice.png: 3 px dashes
  /// with 2 px gaps).
  static const double dashLength = 3;
  static const double dashGap = 2;

  /// The height of the Practice category cards. practice.png measures 80 px
  /// (border to border) → 67 dp; raised a little on request. A minimum: a
  /// card grows when its text needs more room (large fonts).
  static const double categoryCardHeight = 74;

  /// The height of the Practice "Custom session" row. Its content (the
  /// `customIconCircle` plus padding) measures 49 dp; raised with the cards
  /// so the section keeps its rhythm. Also a minimum.
  static const double customSessionRowHeight = 56;

  /// home.png bar base → W-label row ≈ 35 px.
  static const double chartLabelReserve = 28;

  /// Home never scrolls on a phone: its chart absorbs the screen height,
  /// growing or shrinking the plot from the mockup's [chartPlotHeight]. The
  /// plot never goes below this; only when the other blocks plus this
  /// minimum exceed the viewport (landscape, split screen, very large
  /// accessibility text) does Home scroll.
  static const double chartPlotMinHeight = 60;

  /// The plot never grows past this (the mockup's own height); on taller
  /// phones the remaining height widens the gaps between Home's blocks
  /// instead.
  static const double chartPlotMaxHeight = chartPlotHeight;
}

/// Corner radii in dp (theme-tokens.md §4) plus ready-made [BorderRadius]es.
abstract final class AppRadius {
  /// Chart card, quick start cards, Weak Spots card, nav bar, nav pill.
  static const double lg = 18;

  /// Stat tiles, sessions block, category cards, custom session row,
  /// session-type cards, Start button, app icon.
  static const double md = 14;

  /// Chips, segment thumb, back button.
  static const double sm = 8;

  /// Level/time badges, accuracy bar tops, legend square.
  static const double xs = 4;

  /// Difficulty and Answers tracks.
  static const double track = 12;

  /// Play circles, radio, speed dot.
  static const double full = 999;

  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius trackAll = BorderRadius.all(Radius.circular(track));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));

  /// Modal sheet: rounded top corners only.
  static const BorderRadius lgTop = BorderRadius.vertical(
    top: Radius.circular(lg),
  );
}

/// Text styles (theme-tokens.md §5). The family is the platform default
/// (`fontFamily: null` — Roboto on Android, SF on iOS).
///
/// Line heights: the tokens only fix `helper` (1.4). Flutter's default
/// Roboto line box is ≈ 1.45 × the size, which made every label → value gap
/// ~10 dp looser than the mockups; single-line styles therefore use
/// `height: 1.0` (box = font size, as measured in the images) and the
/// wrapping body/subtitle styles 1.2.
abstract final class AppTextStyles {
  /// "Backsolve", "Practice".
  static const TextStyle screenTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.ink,
  );

  /// Session Setup title.
  static const TextStyle pageTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.ink,
  );

  /// Quick start card titles (recolour with [AppColors.onPrimary] on teal).
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.ink,
  );

  /// Accuracy/Speed values, session counters.
  static const TextStyle statValue = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.ink,
  );

  /// Category card names.
  static const TextStyle categoryName = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.ink,
  );

  /// Session-type card titles.
  static const TextStyle optionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.ink,
  );

  /// "Custom session" row title.
  static const TextStyle optionTitleCompact = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.ink,
  );

  /// Default body.
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.ink,
  );

  /// Card subtitles, tagline.
  static const TextStyle subtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.textSecondary,
  );

  /// Difficulty/Answers helper lines.
  static const TextStyle helper = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Uppercase section headers and in-card overlines.
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  /// Tile deltas ("+5 this week").
  static const TextStyle delta = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.primary,
  );

  /// Counter labels, axis labels, legend.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.0,
    color: AppColors.textSecondary,
  );

  /// Settings chips (recolour with [AppColors.onPrimary] on teal).
  static const TextStyle chip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.ink,
  );

  /// Category badges.
  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.ink,
  );

  static const TextStyle segmentSelected = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.ink,
  );

  static const TextStyle segmentUnselected = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.0,
    color: AppColors.textSegment,
  );

  static const TextStyle navLabelActive = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.ink,
  );

  static const TextStyle navLabelInactive = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.0,
    color: AppColors.navInactive,
  );

  /// Start button.
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.onPrimary,
  );

  /// Home quick start second line.
  static const TextStyle quickStartSummary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.onPrimarySubtle,
  );
}

/// The app's [ThemeData]: Material 3 with the §1 colour-scheme mapping.
ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.radioRing,
    surfaceContainerLow: AppColors.surfaceMuted,
    surfaceContainerHigh: AppColors.segmentTrack,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    splashFactory: NoSplash.splashFactory,
    fontFamily: null,
  );
}
