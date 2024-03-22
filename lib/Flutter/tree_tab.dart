import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class TreeTab extends StatefulWidget {
  final double treeState;
  final VoidCallback? refreshTreeTab;

  TreeTab({Key? key, required this.treeState, this.refreshTreeTab}) : super(key: key);

  @override
  _TreeTabState createState() => _TreeTabState();
}

class _TreeTabState extends State<TreeTab> {
  StateMachineController? controller;
  SMIInput<double>? inputValue;

  @override
  void didUpdateWidget(TreeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the input value when the tree state changes
    if (widget.treeState != oldWidget.treeState) {
      inputValue?.change(widget.treeState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tree"),
      ),
      body: Stack(
        children: [
          RiveAnimation.asset("assets/tree-demo.riv", fit: BoxFit.contain,
              onInit: (artboard) {
                controller = StateMachineController.fromArtboard(
                  artboard,
                  "State Machine 1",
                );

                if (controller != null) {
                  artboard.addController(controller!);
                  inputValue = controller?.findInput("input");
                  inputValue?.change(widget.treeState);
                }
              })
        ],
      ),
    );
  }
}


