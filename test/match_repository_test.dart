import 'package:futstats/repositories/match_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futstats/repositories/match_repository.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/services/firestore_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockFirestoreService extends Mock implements FirestoreService {}

class MockMatch extends Mock implements Match {}

void main() {
  late MatchRepository matchRepository;
  late MockFirestoreService mockFirestoreService;
  const seasonId = 'season123';
  const matchId = 'match456';

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    matchRepository = MatchRepository(seasonId: seasonId);
    // Inject the mock FirestoreService
    matchRepository = MatchRepository(seasonId: seasonId)
      .._firestoreService = mockFirestoreService;
  });

  group('MatchRepository', () {
    test('setMatch calls FirestoreService.setDocument with correct arguments', () async {
      final match = MockMatch();
      when(match.id).thenReturn(matchId);
      when(match.toMap()).thenReturn({'id': matchId});

      await matchRepository.setMatch(match);

      verify(mockFirestoreService.setDocument(
        matchRepository.collectionPath,
        matchId,
        {'id': matchId},
      )).called(1);
    });

    test('getMatch returns Match when document exists', () async {
      final data = {'id': matchId, 'matchweek': 1};
      final mockDoc = MockDocumentSnapshot(data, exists: true);
      when(mockFirestoreService.getDocument(any, any)).thenAnswer((_) async => mockDoc);

      final result = await matchRepository.getMatch(matchId);

      expect(result, isA<Match>());
      expect(result?.id, matchId);
    });

    test('getMatch returns null when document does not exist', () async {
      final mockDoc = MockDocumentSnapshot({}, exists: false);
      when(mockFirestoreService.getDocument(any, any)).thenAnswer((_) async => mockDoc);

      final result = await matchRepository.getMatch(matchId);

      expect(result, isNull);
    });

    test('deleteMatch calls FirestoreService.deleteDocument with correct arguments', () async {
      await matchRepository.deleteMatch(matchId);

      verify(mockFirestoreService.deleteDocument(
        matchRepository.collectionPath,
        matchId,
      )).called(1);
    });

    test('getAllMatches returns sorted list of Match by matchweek', () async {
      final docs = [
        MockQueryDocumentSnapshot({'id': '1', 'matchweek': 2}),
        MockQueryDocumentSnapshot({'id': '2', 'matchweek': 1}),
        MockQueryDocumentSnapshot({'id': '3', 'matchweek': 3}),
      ];
      final mockQuerySnapshot = MockQuerySnapshot(docs);
      when(mockFirestoreService.getCollection(any)).thenAnswer((_) async => mockQuerySnapshot);

      final result = await matchRepository.getAllMatches();

      expect(result, isA<List<Match>>());
      expect(result.length, 3);
      expect(result[0].matchweek, 1);
      expect(result[1].matchweek, 2);
      expect(result[2].matchweek, 3);
    });
  });
}

// Helper mocks for Firestore snapshots
class MockDocumentSnapshot {
  final Map<String, dynamic> _data;
  final bool exists;
  MockDocumentSnapshot(this._data, {required this.exists});
  Map<String, dynamic>? data() => _data;
}

class MockQueryDocumentSnapshot {
  final Map<String, dynamic> _data;
  MockQueryDocumentSnapshot(this._data);
  Map<String, dynamic>? data() => _data;
}

class MockQuerySnapshot {
  final List<MockQueryDocumentSnapshot> docs;
  MockQuerySnapshot(this.docs);
}


