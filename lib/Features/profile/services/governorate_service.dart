import 'package:Tosell/Features/profile/models/zone.dart';
import 'package:Tosell/core/Client/BaseClient.dart';

class GovernorateService {
  final BaseClient<Governorate> baseClient;

  GovernorateService()
      : baseClient = BaseClient<Governorate>(
            fromJson: (json) => Governorate.fromJson(json));
  Future<List<Governorate>> getAllZones(
      {Map<String, dynamic>? queryParams, int page = 1}) async {
    try {
      var result = await baseClient.getAll(
          endpoint: '/governorate', page: page, queryParams: queryParams);

      if (result.data == null) {
        return [];
      }

      return result.data!;
    } catch (e) {
      rethrow;
    }
  }
  Future<List<Governorate>> searchGovernorates(String query,
      {int page = 1}) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllZones(page: page);
      }

      final allGovernorates = await getAllZones(page: page);
      final searchResults = allGovernorates
          .where((gov) =>
              gov.name?.toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList();

      return searchResults;
    } catch (e) {
      rethrow;
    }
  }  Future<Governorate?> getGovernorateById(int id) async {
    try {
      final result = await baseClient.getById(
        endpoint: '/governorate',
        id: id.toString(),
      );

      return result.getSingle;
    } catch (e) {
      rethrow;
    }
  }
}
