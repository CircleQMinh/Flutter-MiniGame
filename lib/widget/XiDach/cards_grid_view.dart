import 'package:flutter/material.dart';

class CardsGridView extends StatelessWidget {
  const CardsGridView({
    Key? key,
    required this.cards,
  }) : super(key: key);

  final List<Image> cards;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9.0, top: 9.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.green,
        boxShadow: [
          const BoxShadow(color: Colors.yellow, spreadRadius: 2),
        ],
      ),
      height: 200,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 1, bottom: 3, top: 3),
            child: AnimatedOpacity(
              opacity: 1,
              duration: const Duration(seconds: 1),
              child: cards[index],
            ),
          );
        },
      ),
    );
  }
}
