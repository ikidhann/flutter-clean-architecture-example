import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rickmorty/layers/domain/entity/character.dart';
import 'package:rickmorty/layers/domain/usecase/get_all_characters.dart';

part 'character_page_state.dart';

class CharacterPageCubit extends Cubit<CharacterPageState> {
  CharacterPageCubit({
    required GetAllCharacters getAllCharacters,
  })  : _getAllCharacters = getAllCharacters,
        super(const CharacterPageState());

  final GetAllCharacters _getAllCharacters;
  bool _isThrottling = false;
  static const Duration throttleDuration = Duration(milliseconds: 100);

  Future<void> fetchNextPage() async {
    if (_isThrottling) return;

    _isThrottling = true;
    await _fetchNextPage();
    Future.delayed(throttleDuration, () {
      _isThrottling = false;
    });
  }

  Future<void> _fetchNextPage() async {
    if (state.hasReachedEnd) return;

    emit(state.copyWith(status: CharacterPageStatus.loading));

    try {
      final list = await _getAllCharacters(page: state.currentPage);

      emit(
        state.copyWith(
          status: CharacterPageStatus.success,
          hasReachedEnd: list.isEmpty,
          currentPage: state.currentPage + 1,
          characters: List.of(state.characters)..addAll(list),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: CharacterPageStatus.failure));
    }
  }
}
