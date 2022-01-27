import 'package:flutter/material.dart';
import 'package:number_painter/core/rewards.dart';
import 'package:number_painter/screens/svg_view/widgets/painter_inherited.dart';

class RewardButton extends StatefulWidget {
  final Rewards rewards;
  const RewardButton({required this.rewards, Key? key}) : super(key: key);

  @override
  _RewardButtonState createState() => _RewardButtonState();
}

class _RewardButtonState extends State<RewardButton> with SingleTickerProviderStateMixin {
  static const double _lowerBound = -70;
  static const double _upperBound = 20;
  late final AnimationController _rewardController =
      AnimationController(vsync: this, duration: const Duration(seconds: 1), lowerBound: _lowerBound, upperBound: _upperBound)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            Future.delayed(const Duration(seconds: 5), () {
              _rewardController.animateBack(_lowerBound);
            });
          }
          if (status == AnimationStatus.dismissed) {
            Future.delayed(const Duration(seconds: 30), () {
              _rewardController.forward(from: _lowerBound);
            });
          }
        })
        ..addListener(() {
          setState(() {});
        });

  @override
  void dispose() {
    _rewardController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //if (!PainterInherited.of(context).painterProgress.isCompleted) {
    Future.delayed(
      const Duration(seconds: 5),
      () {
        _rewardController.forward(from: _lowerBound);
      },
    );
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 100,
      left: _rewardController.value,
      child: GestureDetector(
        onTap: () {
          widget.rewards.showRewardedAd(PainterInherited.of(context).rewardCallback);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.yellow[800]!, width: 2),
              ),
              height: 60,
              width: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    '+2',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.lightbulb_rounded),
                ],
              ),
            ),
            Positioned(
              bottom: -5,
              right: -10,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.yellow[800]!, width: 2),
                ),
                height: 30,
                width: 30,
                child: const Text(
                  'AD',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
