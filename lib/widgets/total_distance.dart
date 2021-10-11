import 'package:flutter/material.dart';
import 'package:flutter_google_maps/model/directions.dart';

class TotalDistance extends StatelessWidget {
  const TotalDistance({
    Key? key,
    required Directions? info,
  })  : _info = info,
        super(key: key);

  final Directions? _info;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20.0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 6.0,
          horizontal: 12.0,
        ),
        decoration: BoxDecoration(
          color: Colors.yellowAccent,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 20),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Text(
          '${_info!.totalDistance}, ${_info!.totalDuration}',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
