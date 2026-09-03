class RoomSummary {
  const RoomSummary({
    required this.id,
    required this.name,
    required this.members,
  });

  final String id;
  final String name;
  final int members;
}

class RoomService {
  const RoomService();

  List<RoomSummary> get rooms => const [
        RoomSummary(id: 'general', name: 'الغرفة العامة', members: 128),
        RoomSummary(id: 'music', name: 'ليالي الموسيقى', members: 64),
      ];
}