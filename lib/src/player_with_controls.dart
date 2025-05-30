import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/helpers/adaptive_controls.dart';
import 'package:chewie/src/notifiers/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PlayerWithControls extends StatefulWidget {
  const PlayerWithControls({super.key});

  @override
  State<PlayerWithControls> createState() => _PlayerWithControlsState();
}

class _PlayerWithControlsState extends State<PlayerWithControls> {
  VideoPlayerController? _controller;

  void _playingListener() {
    final playing = _controller?.value.isPlaying ?? false;
    final playerNotifier = Provider.of<PlayerNotifier>(context, listen: false);

    if (playing && !playerNotifier.hasPlayedOnce) {
      playerNotifier.hasPlayedOnce = true;
      _controller?.removeListener(_playingListener);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final controller = ChewieController.of(context).videoPlayerController;
    final playerNotifier = Provider.of<PlayerNotifier>(context, listen: false);

    if (_controller != controller) {
      _controller?.removeListener(_playingListener);

      if (!playerNotifier.hasPlayedOnce) {
        _controller = controller;
        controller.addListener(_playingListener);
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_playingListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChewieController chewieController = ChewieController.of(context);

    double calculateAspectRatio(BuildContext context) {
      final size = MediaQuery.of(context).size;
      final width = size.width;
      final height = size.height;

      return width > height ? width / height : height / width;
    }

    Widget buildControls(
      BuildContext context,
      ChewieController chewieController,
    ) {
      return chewieController.showControls
          ? chewieController.customControls ?? const AdaptiveControls()
          : const SizedBox();
    }

    Widget buildPlayerWithControls(
      ChewieController chewieController,
      BuildContext context,
    ) {
      return Stack(
        children: <Widget>[
          InteractiveViewer(
            transformationController: chewieController.transformationController,
            maxScale: chewieController.maxScale,
            panEnabled: chewieController.zoomAndPan,
            scaleEnabled: chewieController.zoomAndPan,
            child: Center(
              child: AspectRatio(
                aspectRatio: chewieController.aspectRatio ??
                    chewieController.videoPlayerController.value.aspectRatio,
                child: VideoPlayer(chewieController.videoPlayerController),
              ),
            ),
          ),
          if (chewieController.placeholder != null)
            Consumer<PlayerNotifier>(
              builder: (context, notifier, _) {
                return notifier.hasPlayedOnce
                    ? const SizedBox.shrink()
                    : chewieController.placeholder!;
              },
            ),
          if (chewieController.overlay != null) chewieController.overlay!,
          if (Theme.of(context).platform != TargetPlatform.iOS)
            Consumer<PlayerNotifier>(
              builder: (
                BuildContext context,
                PlayerNotifier notifier,
                Widget? widget,
              ) =>
                  Visibility(
                visible: !notifier.hideStuff,
                child: AnimatedOpacity(
                  opacity: notifier.hideStuff ? 0.0 : 0.8,
                  duration: const Duration(
                    milliseconds: 250,
                  ),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black54),
                    child: SizedBox.expand(),
                  ),
                ),
              ),
            ),
          if (!chewieController.isFullScreen)
            buildControls(context, chewieController)
          else
            SafeArea(
              bottom: false,
              child: buildControls(context, chewieController),
            ),
        ],
      );
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Center(
        child: SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: AspectRatio(
            aspectRatio: calculateAspectRatio(context),
            child: buildPlayerWithControls(chewieController, context),
          ),
        ),
      );
    });
  }
}
