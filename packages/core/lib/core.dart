/// ThengaPari shared core — public API barrel.
///
/// Apps depend on `core` and `import 'package:core/core.dart';` to get the
/// shared models, services, providers, theme tokens, painters, widgets, and the
/// shared auth screens. Role-specific UI lives in each app, not here.
library;

// ── App-wide theme + flavor ──
export 'app/design_tokens.dart';
export 'app/theme.dart';
export 'app/flavor_config.dart';

// ── i18n ──
export 'core/i18n/app_strings.dart';

// ── Models ──
export 'core/models/amc_contract.dart';
export 'core/models/app_user.dart';
export 'core/models/b2b_buyer_profile.dart';
export 'core/models/b2b_order.dart';
export 'core/models/b2b_savings.dart';
export 'core/models/byproduct.dart';
export 'core/models/crop_listing.dart';
export 'core/models/crop_summary.dart';
export 'core/models/harvest_job.dart';
export 'core/models/inventory_listing.dart';
export 'core/models/job_status_update.dart';
export 'core/models/job_step.dart';
export 'core/models/processor_response.dart';
export 'core/models/site_manager_profile.dart';
export 'core/models/standing_order.dart';
export 'core/models/tree_inventory.dart';
export 'core/models/worker_profile.dart';
export 'core/models/yield_data.dart';
export 'core/models/yield_estimate.dart';

// ── Services ──
export 'core/services/auth_service.dart';
export 'core/services/b2b_service.dart';
export 'core/services/homeowner_service.dart';
export 'core/services/onboarding_service.dart';
export 'core/services/site_manager_service.dart';
export 'core/services/worker_service.dart';

// ── Providers ──
export 'core/providers/auth_provider.dart';
export 'core/providers/b2b_providers.dart';
export 'core/providers/homeowner_providers.dart';
export 'core/providers/locale_provider.dart';
export 'core/providers/onboarding_provider.dart';
export 'core/providers/site_manager_providers.dart';
export 'core/providers/worker_providers.dart';

// ── Shared widgets ──
export 'core/widgets/app_button.dart';
export 'core/widgets/app_icon.dart';
export 'core/widgets/app_text_field.dart';
export 'core/widgets/countdown_timer_widget.dart';
export 'core/widgets/crop_inventory_row.dart';
export 'core/widgets/hero_landscape_widget.dart';
export 'core/widgets/job_status_badge.dart';
export 'core/widgets/job_status_card.dart';
export 'core/widgets/live_inventory_tile.dart';
export 'core/widgets/role_nav_bars.dart';
export 'core/widgets/savings_band_widget.dart';
export 'core/widgets/shimmer_job_card.dart';
export 'core/widgets/stat_card.dart';
export 'core/widgets/user_avatar_widget.dart';
export 'core/widgets/worker_availability_toggle.dart';
export 'core/widgets/worker_job_detail_row.dart';

// ── Painters ──
export 'core/widgets/painters/kerala_landscape_painter.dart';
export 'core/widgets/painters/radar_map_painter.dart';
export 'core/widgets/painters/savings_bar_chart_painter.dart';
export 'core/widgets/painters/weekly_earnings_chart_painter.dart';
export 'core/widgets/painters/yield_donut_painter.dart';

// ── Shared auth screens ──
export 'features/auth/screens/login_screen.dart';
export 'features/auth/screens/onboarding_screen.dart';
export 'features/auth/screens/otp_verify_screen.dart';
export 'features/auth/screens/role_gate_screen.dart';
export 'features/auth/screens/splash_screen.dart';
export 'features/auth/widgets/auth_widgets.dart';
export 'features/auth/widgets/onboarding_illustrations.dart';
