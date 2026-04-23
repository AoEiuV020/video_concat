part of 'trim_viewmodel.dart';

final class _TrimViewModelPreview {
  _TrimViewModelPreview(this.vm);

  final TrimViewModel vm;

  TrimState get state => vm.currentState;
  set state(TrimState value) => vm.currentState = value;

  Future<void> syncResolvedPosition(int targetUs) async {
    if (vm.isDisposed) return;

    final actualTs = vm._resolvePlayerSeekTarget(targetUs);
    final requestId = ++vm.previewRequestId;
    vm.activePreviewRequestId = requestId;
    vm.previewPendingTimer?.cancel();

    state = state.copyWith(
      currentPositionUs: targetUs,
      draggingPositionUs: null,
      isPreviewPending: true,
      pendingPreviewTargetUs: actualTs,
    );

    vm.previewPendingTimer = Timer(TrimViewModel._previewPendingTimeout, () {
      if (vm.isDisposed || vm.activePreviewRequestId != requestId) return;
      if (!state.isPreviewPending || state.pendingPreviewTargetUs != actualTs) {
        return;
      }
      logger.w('预览画面同步超时 videoId=${state.videoId} targetUs=$actualTs');
      clearPreviewPending();
    });

    await vm._seekPlayer(targetUs);
    if (vm.isDisposed || vm.activePreviewRequestId != requestId) return;
    completePreviewPendingIfMatched(vm.player.state.position.inMicroseconds);
  }

  void clearPreviewPending() {
    vm.previewPendingTimer?.cancel();
    vm.activePreviewRequestId = null;
    if (!state.isPreviewPending && state.pendingPreviewTargetUs == null) {
      return;
    }
    state = state.copyWith(
      isPreviewPending: false,
      pendingPreviewTargetUs: null,
    );
  }

  void completePreviewPendingIfMatched(int positionUs) {
    if (vm.isDisposed || !matchesPreviewTarget(positionUs)) return;
    logger.i('预览画面已同步 videoId=${state.videoId} positionUs=$positionUs');
    clearPreviewPending();
  }

  bool matchesPreviewTarget(int positionUs) {
    final targetUs = state.pendingPreviewTargetUs;
    if (!state.isPreviewPending || targetUs == null) return false;
    return (positionUs - targetUs).abs() <=
        TrimViewModel._previewMatchToleranceUs;
  }
}
