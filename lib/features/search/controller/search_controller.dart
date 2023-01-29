import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media/features/search/respository/search_repository.dart';
import 'package:social_media/models/user_model.dart';

final searchUserProvider =
    StreamProvider.family<List<UserModel>, String>((ref, String query) {
  final controller = ref.watch(searchControllerProvider.notifier);
  return controller.searchUser(query);
});

final searchControllerProvider =
    StateNotifierProvider<SearchController, bool>((ref) {
  return SearchController(
      searchRepository: ref.watch(searchRepositoryProvider));
});

class SearchController extends StateNotifier<bool> {
  final SearchRepository _searchRepository;
  SearchController({required SearchRepository searchRepository})
      : _searchRepository = searchRepository,
        super(false);

  // Search the user with query.
  Stream<List<UserModel>> searchUser(String query) {
    return _searchRepository.searchUser(query);
  }
}
