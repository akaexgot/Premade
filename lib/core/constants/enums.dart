enum GameType { leagueOfLegends, valorant }

enum RankType { iron, bronze, silver, gold, platinum, diamond, master, grandmaster, challenger }

enum RoleType { top, jungle, mid, adc, support, duelist, sentinel, controller, initiator }

enum GameMode { ranked, casual }

enum OnlineStatus { online, offline, away }

enum UserRelationshipStatus { none, friend, blocked, blocked_by, pending }

enum SwipeAction { like, dislike, superlike }

extension GameTypeExtension on GameType {
  String get displayName {
    switch (this) {
      case GameType.leagueOfLegends:
        return 'League of Legends';
      case GameType.valorant:
        return 'Valorant';
    }
  }
}

extension RankTypeExtension on RankType {
  String get displayName {
    switch (this) {
      case RankType.iron:
        return 'Iron';
      case RankType.bronze:
        return 'Bronze';
      case RankType.silver:
        return 'Silver';
      case RankType.gold:
        return 'Gold';
      case RankType.platinum:
        return 'Platinum';
      case RankType.diamond:
        return 'Diamond';
      case RankType.master:
        return 'Master';
      case RankType.grandmaster:
        return 'Grandmaster';
      case RankType.challenger:
        return 'Challenger';
    }
  }
}
