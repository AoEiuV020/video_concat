part of 'trim_viewmodel.dart';

final class _TrimViewModelSegments {
  _TrimViewModelSegments(this.vm);

  final TrimViewModel vm;

  TrimState get state => vm.currentState;
  set state(TrimState value) => vm.currentState = value;

  void setInpoint() {
    logger.d('setInpoint currentPositionUs=${state.currentPositionUs}');
    state = state.copyWith(pendingInpointUs: state.currentPositionUs);
  }

  String? setOutpoint() {
    final current = state.currentPositionUs;
    final pending = state.pendingInpointUs;
    final isVirtualEnd = current == state.durationUs;
    final outpointDts = isVirtualEnd ? null : vm.cache.getDts(current);

    logger.d(
      'setOutpoint current=$current outpoint=${isVirtualEnd ? state.durationUs : current} '
      'pending=$pending outpointDts=$outpointDts '
      'isVirtualEnd=$isVirtualEnd',
    );

    final result = applyTrimOutpoint(
      segments: state.segments,
      pendingInpointUs: pending,
      currentPositionUs: current,
      durationUs: state.durationUs,
      outpointDtsUs: outpointDts,
    );

    if (result.errorMessage != null) {
      return result.errorMessage;
    }

    state = state.copyWith(
      segments: result.segments,
      pendingInpointUs: result.pendingInpointUs,
    );
    return null;
  }

  void removePendingInpoint() {
    logger.d('removePendingInpoint');
    state = state.copyWith(pendingInpointUs: null);
  }

  void removeSegment(int index) {
    final segments = [...state.segments]..removeAt(index);
    state = state.copyWith(segments: segments);
  }

  void confirm() {
    final homeVm = vm.homeViewModel;
    if (state.segments.isEmpty) {
      homeVm.setTrimConfig(state.videoId, null);
    } else {
      homeVm.setTrimConfig(state.videoId, TrimConfig(segments: state.segments));
    }
  }
}
