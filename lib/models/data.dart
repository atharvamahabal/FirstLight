class WheelSegment {
  final String label;
  final String emoji;
  final String category;
  final int color;
  final int xp;
  final int? timerSeconds; // null = no timer
  final bool hasTextInput; // for "write a thought"

  const WheelSegment({
    required this.label,
    required this.emoji,
    required this.category,
    required this.color,
    required this.xp,
    this.timerSeconds,
    this.hasTextInput = false,
  });
}

class ActivityEntry {
  final String type;
  final String label;
  final String emoji;
  final int xp;
  final String? category;
  final int timestampMs;

  const ActivityEntry({
    required this.type,
    required this.label,
    required this.emoji,
    required this.xp,
    required this.timestampMs,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'label': label,
        'emoji': emoji,
        'xp': xp,
        'category': category,
        'timestampMs': timestampMs,
      };

  factory ActivityEntry.fromJson(Map<String, dynamic> json) => ActivityEntry(
        type: json['type'] as String,
        label: json['label'] as String,
        emoji: json['emoji'] as String,
        xp: (json['xp'] as num).toInt(),
        category: json['category'] as String?,
        timestampMs: (json['timestampMs'] as num).toInt(),
      );
}

class RitualItem {
  final String emoji;
  final String name;
  final String duration;
  final int? timerSeconds;
  final int xp;
  bool done;

  RitualItem({
    required this.emoji,
    required this.name,
    required this.duration,
    this.timerSeconds,
    required this.xp,
    this.done = false,
  });
}

class Badge {
  final String icon;
  final String name;
  final String tier;
  final String description;
  final BadgeColor color;
  final bool locked;

  const Badge({
    required this.icon,
    required this.name,
    required this.tier,
    required this.description,
    required this.color,
    this.locked = false,
  });
}

enum BadgeColor { purple, amber, mint, pink }

// ── Wheel Segments (20 random challenges) ────────────────────────────────────
const List<WheelSegment> wheelSegments = [
  WheelSegment(label: '10 Pushups',      emoji: '💪', category: 'BODY',    color: 0xFF7C3AED, xp: 10),
  WheelSegment(label: 'Cold Splash',     emoji: '💧', category: 'BODY',    color: 0xFF2563EB, xp: 8),
  WheelSegment(label: 'Read 1 Page',     emoji: '📖', category: 'MIND',    color: 0xFF059669, xp: 5),
  WheelSegment(label: 'Write a Thought', emoji: '✍️', category: 'MIND',    color: 0xFF3DE8A0, xp: 8, hasTextInput: true),
  WheelSegment(label: 'Breathe 1 min',   emoji: '🧘', category: 'CALM',    color: 0xFF9B7FF4, xp: 5, timerSeconds: 60),
  WheelSegment(label: 'No Phone 30min',  emoji: '📵', category: 'CALM',    color: 0xFFDB2777, xp: 15, timerSeconds: 1800),
  WheelSegment(label: 'Work 15 mins',    emoji: '🎯', category: 'HUSTLE',  color: 0xFFF5A623, xp: 15, timerSeconds: 900),
  WheelSegment(label: 'Wild Card!',      emoji: '🎲', category: 'WILD',    color: 0xFFF472B6, xp: 12),
  WheelSegment(label: '20 Squats',       emoji: '🏋️', category: 'BODY',   color: 0xFF7C3AED, xp: 10),
  WheelSegment(label: '5 Min Walk',      emoji: '🚶', category: 'BODY',    color: 0xFF0891B2, xp: 8, timerSeconds: 300),
  WheelSegment(label: 'Gratitude Note',  emoji: '🙏', category: 'MIND',    color: 0xFFD97706, xp: 8, hasTextInput: true),
  WheelSegment(label: 'Meditate 2min',   emoji: '🌿', category: 'CALM',    color: 0xFF059669, xp: 10, timerSeconds: 120),
  WheelSegment(label: 'Drink Water',     emoji: '💧', category: 'BODY',    color: 0xFF0EA5E9, xp: 5),
  WheelSegment(label: 'Smile Challenge', emoji: '😄', category: 'WILD',    color: 0xFFF472B6, xp: 5),
  WheelSegment(label: 'Plan Your Day',   emoji: '📋', category: 'HUSTLE',  color: 0xFFF5A623, xp: 10, hasTextInput: true),
  WheelSegment(label: 'Power Pose 1min', emoji: '🦸', category: 'BODY',    color: 0xFF7C3AED, xp: 8, timerSeconds: 60),
  WheelSegment(label: '10 Jumping Jacks',emoji: '⚡', category: 'BODY',    color: 0xFFDB2777, xp: 8),
  WheelSegment(label: 'Journal 3 Lines', emoji: '📓', category: 'MIND',    color: 0xFF3DE8A0, xp: 10, hasTextInput: true),
  WheelSegment(label: 'Cold Water Face', emoji: '🧊', category: 'BODY',    color: 0xFF0EA5E9, xp: 8),
  WheelSegment(label: 'Set 1 Goal',      emoji: '🏆', category: 'HUSTLE',  color: 0xFFF5A623, xp: 12, hasTextInput: true),
];

// ── Ritual Items ──────────────────────────────────────────────────────────────
final List<RitualItem> defaultRituals = [
  RitualItem(emoji: '💧', name: 'Drink a glass of water', duration: '1 min',  xp: 5),
  RitualItem(emoji: '🧘', name: 'Breathe deeply',         duration: '2 mins', xp: 8,  timerSeconds: 120),
  RitualItem(emoji: '✍️', name: 'Write one sentence',     duration: '3 mins', xp: 8),
  RitualItem(emoji: '💪', name: '10 pushups',             duration: '2 mins', xp: 10),
  RitualItem(emoji: '🎯', name: "Review today's goal",    duration: '2 mins', xp: 8),
  RitualItem(emoji: '🌤️', name: 'Look outside',          duration: '1 min',  xp: 5),
];

// Preview / upcoming rituals (greyed out)
final List<RitualItem> upcomingRituals = [
  RitualItem(emoji: '📖', name: 'Read one page',          duration: '5 mins', xp: 8),
  RitualItem(emoji: '🧴', name: 'Skincare routine',       duration: '3 mins', xp: 5),
  RitualItem(emoji: '🏃', name: 'Morning jog',            duration: '15 mins',xp: 15),
];

// ── 50 Badges ────────────────────────────────────────────────────────────────
const List<Badge> badges = [
  // Earned (first 10 unlocked as examples)
  Badge(icon: '🔥', name: 'First Flame',     tier: 'BRONZE',  description: 'Complete your very first task',            color: BadgeColor.amber),
  Badge(icon: '⚡', name: '7-Day Streak',    tier: 'SILVER',  description: 'Maintain a 7-day streak',                  color: BadgeColor.purple),
  Badge(icon: '💪', name: 'Body Warrior',    tier: 'GOLD',    description: 'Complete 10 body challenges',              color: BadgeColor.amber),
  Badge(icon: '🧘', name: 'Zen Master',      tier: 'SILVER',  description: 'Complete 5 calm challenges',               color: BadgeColor.mint),
  Badge(icon: '🎯', name: 'Hustle King',     tier: 'BRONZE',  description: 'Complete 5 hustle tasks',                  color: BadgeColor.purple),
  Badge(icon: '🌅', name: 'Early Bird',      tier: 'GOLD',    description: 'Open app before 7am 5 times',              color: BadgeColor.amber),
  Badge(icon: '🎰', name: 'Lucky 777',       tier: 'RARE',    description: 'Hit a jackpot in the 777 slots',           color: BadgeColor.pink),
  Badge(icon: '✍️', name: 'Thought Leader',  tier: 'BRONZE',  description: 'Write 5 thoughts',                         color: BadgeColor.mint),
  Badge(icon: '💧', name: 'Hydration Hero',  tier: 'BRONZE',  description: 'Drink water 7 days in a row',              color: BadgeColor.purple),
  Badge(icon: '🌿', name: 'Inner Peace',     tier: 'SILVER',  description: 'Meditate for 10 cumulative minutes',       color: BadgeColor.mint),

  // Locked — progression trophies
  Badge(icon: '🏆', name: '30-Day Legend',   tier: 'DIAMOND', description: 'Maintain a 30-day streak',                 color: BadgeColor.purple, locked: true),
  Badge(icon: '💎', name: 'Elite Mind',      tier: 'DIAMOND', description: 'Complete all MIND challenges',             color: BadgeColor.mint,   locked: true),
  Badge(icon: '🌟', name: 'Rising Star',     tier: 'GOLD',    description: 'Reach 1000 XP',                            color: BadgeColor.amber,  locked: true),
  Badge(icon: '🚀', name: 'Launch Pad',      tier: 'SILVER',  description: 'Complete 20 morning rituals',              color: BadgeColor.purple, locked: true),
  Badge(icon: '🦅', name: 'Eagle Eye',       tier: 'GOLD',    description: 'Spin the wheel 50 times',                  color: BadgeColor.amber,  locked: true),
  Badge(icon: '🌊', name: 'Flow State',      tier: 'SILVER',  description: 'Complete all 6 rituals in one day',        color: BadgeColor.mint,   locked: true),
  Badge(icon: '🏋️', name: 'Iron Will',      tier: 'GOLD',    description: 'Complete 25 body challenges',              color: BadgeColor.purple, locked: true),
  Badge(icon: '🧠', name: 'Galaxy Brain',    tier: 'DIAMOND', description: 'Complete 30 mind challenges',              color: BadgeColor.pink,   locked: true),
  Badge(icon: '🎪', name: 'Wild One',        tier: 'RARE',    description: 'Land on Wild Card 5 times',                color: BadgeColor.pink,   locked: true),
  Badge(icon: '📚', name: 'Bookworm',        tier: 'BRONZE',  description: 'Read 10 pages total',                      color: BadgeColor.mint,   locked: true),
  Badge(icon: '🌈', name: 'All Rounder',     tier: 'GOLD',    description: 'Complete tasks in all categories',         color: BadgeColor.amber,  locked: true),
  Badge(icon: '🕰️', name: 'Time Lord',      tier: 'SILVER',  description: 'Complete 10 timed tasks',                  color: BadgeColor.purple, locked: true),
  Badge(icon: '🤸', name: 'Flex God',        tier: 'BRONZE',  description: 'Do 100 pushups total',                     color: BadgeColor.amber,  locked: true),
  Badge(icon: '🌙', name: 'Night Owl',       tier: 'BRONZE',  description: 'Open app after 10pm',                      color: BadgeColor.mint,   locked: true),
  Badge(icon: '☀️', name: 'Sunrise Soul',    tier: 'SILVER',  description: 'Open app before 6am 3 times',              color: BadgeColor.amber,  locked: true),
  Badge(icon: '🎭', name: 'Mood Shifter',    tier: 'BRONZE',  description: 'Tap pet 10 times',                         color: BadgeColor.pink,   locked: true),
  Badge(icon: '🔮', name: 'Fortune Seeker',  tier: 'RARE',    description: 'Pull the 777 slots 20 times',              color: BadgeColor.pink,   locked: true),
  Badge(icon: '🌺', name: 'Bloom',           tier: 'SILVER',  description: 'Complete morning ritual 7 days straight',  color: BadgeColor.mint,   locked: true),
  Badge(icon: '⚔️', name: 'Warrior',        tier: 'GOLD',    description: 'Reach 2000 XP',                            color: BadgeColor.purple, locked: true),
  Badge(icon: '🧩', name: 'Puzzle Solver',   tier: 'BRONZE',  description: 'Try every wheel segment once',             color: BadgeColor.amber,  locked: true),
  Badge(icon: '🎵', name: 'In Rhythm',       tier: 'SILVER',  description: 'Complete rituals 14 days straight',        color: BadgeColor.purple, locked: true),
  Badge(icon: '🦋', name: 'Metamorphosis',   tier: 'DIAMOND', description: 'Use app for 60 days',                      color: BadgeColor.pink,   locked: true),
  Badge(icon: '🏅', name: 'Top Achiever',    tier: 'GOLD',    description: 'Earn 30 different badges',                 color: BadgeColor.amber,  locked: true),
  Badge(icon: '🌍', name: 'World Class',     tier: 'DIAMOND', description: 'Reach 5000 XP',                            color: BadgeColor.purple, locked: true),
  Badge(icon: '🎯', name: 'Bullseye',        tier: 'GOLD',    description: 'Complete 10 hustle tasks',                 color: BadgeColor.amber,  locked: true),
  Badge(icon: '🧪', name: 'Experimenter',    tier: 'BRONZE',  description: 'Try 777 slots for first time',             color: BadgeColor.mint,   locked: true),
  Badge(icon: '🌻', name: 'Sunflower',       tier: 'SILVER',  description: 'Look outside 10 times',                   color: BadgeColor.amber,  locked: true),
  Badge(icon: '🦁', name: 'Lionheart',       tier: 'GOLD',    description: 'Complete a 15 XP challenge',               color: BadgeColor.amber,  locked: true),
  Badge(icon: '🎓', name: 'Graduate',        tier: 'SILVER',  description: 'Complete 50 tasks total',                  color: BadgeColor.purple, locked: true),
  Badge(icon: '🌠', name: 'Star Gazer',      tier: 'RARE',    description: 'Complete a task at midnight',              color: BadgeColor.pink,   locked: true),
  Badge(icon: '🏔️', name: 'Summit',         tier: 'DIAMOND', description: 'Maintain a 100-day streak',                color: BadgeColor.purple, locked: true),
  Badge(icon: '🎆', name: 'Celebration',     tier: 'GOLD',    description: 'Earn 1000 XP in a single week',           color: BadgeColor.amber,  locked: true),
  Badge(icon: '🌱', name: 'Seed Planted',    tier: 'BRONZE',  description: 'Complete first ritual',                    color: BadgeColor.mint,   locked: true),
  Badge(icon: '🦊', name: 'Clever Fox',      tier: 'SILVER',  description: 'Win 3 jackpots in 777',                   color: BadgeColor.amber,  locked: true),
  Badge(icon: '🎪', name: 'Show Stopper',    tier: 'RARE',    description: 'Spin wheel 100 times',                     color: BadgeColor.pink,   locked: true),
  Badge(icon: '🌞', name: 'Sunshine',        tier: 'GOLD',    description: 'Complete ritual before 8am 10 times',      color: BadgeColor.amber,  locked: true),
  Badge(icon: '🦄', name: 'Unicorn',         tier: 'DIAMOND', description: 'Complete every single challenge type',     color: BadgeColor.pink,   locked: true),
  Badge(icon: '🔑', name: 'Key Master',      tier: 'GOLD',    description: 'Unlock 20 other badges',                   color: BadgeColor.purple, locked: true),
  Badge(icon: '🎁', name: 'Gift to Self',    tier: 'SILVER',  description: 'Complete 30 tasks',                        color: BadgeColor.mint,   locked: true),
  Badge(icon: '🧲', name: 'Magnetic',        tier: 'BRONZE',  description: 'Use app 3 days in a row',                  color: BadgeColor.purple, locked: true),
  Badge(icon: '🪐', name: 'Orbit',           tier: 'DIAMOND', description: 'Use app every day for 90 days',           color: BadgeColor.mint,   locked: true),
];

// ── Slot Symbols & Combos ─────────────────────────────────────────────────────
const List<String> slotSymbols = ['🏋️', '📚', '💰', '🧘', '🤝', '🎨'];
const List<String> slotNames   = ['Fitness', 'Learning', 'Money', 'Calm', 'Social', 'Creativity'];

const Map<String, String> slotCombos = {
  'Calm+Fitness+Learning':          'Walk to a new spot while listening to a podcast 🎧\nEg: 10-min walk + 1 chapter of an audiobook',
  'Fitness+Fitness+Fitness':        '🎉 JACKPOT! 30-min full body workout + cold shower!\nEg: 20 pushups, 20 squats, 20 jumping jacks × 3 rounds',
  'Learning+Learning+Learning':     '🎉 JACKPOT! Deep learning session — read for 1 hour!\nEg: Pick a book, put phone away, just read',
  'Calm+Calm+Calm':                 '🎉 JACKPOT! Full zen morning — no rush, no phone!\nEg: 5-min breathe → journal → sit in silence',
  'Calm+Creativity+Money':          'Sketch your dream life for 10 mins 🎨\nEg: Draw your ideal day, income, or dream home',
  'Creativity+Learning+Money':      'Work on a passion project for 20 mins 💡\nEg: Build something, write something, design something',
  'Fitness+Learning+Social':        'Call a friend while you walk 🚶\nEg: 15-min walk + catch up with someone you miss',
  'Calm+Social+Creativity':         'Write a kind message to someone 💌\nEg: Text a friend, write a thank-you note',
  'Money+Money+Money':              '🎉 JACKPOT! Finance focus day — review your goals!\nEg: Check savings, set a budget, track one expense',
  'Social+Social+Social':           '🎉 JACKPOT! Connection day — reach out to 3 people!\nEg: Text, call, or meet someone meaningful',
  'Creativity+Creativity+Creativity':'🎉 JACKPOT! Pure creative flow — make something!\nEg: Draw, write, code, cook something new',
  'Fitness+Money+Learning':         'Listen to a finance podcast on a walk 🎙️\nEg: 20-min walk + money mindset episode',
  'Social+Learning+Calm':           'Share one thing you learned with a friend 📲\nEg: Text a fun fact or insight you found recently',
  'Creativity+Fitness+Calm':        'Do yoga or stretching to music 🎶\nEg: 10-min stretch with your favourite playlist on',
  'Money+Calm+Social':              'Reflect on what you\'re grateful for financially 💛\nEg: 3 things money has allowed you to experience',
};
