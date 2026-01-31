import 'package:flutter_herodex3000/barrel_files/models.dart';

abstract class IAgentDataManager {

  Future<void> createHero(AgentModel hero);
  Future<List<AgentModel>> getAllHeroesLocal();
  Future<List<AgentModel>> getHeroByNameLocal(String heroName);
  Future<List<AgentModel>> getHeroByNameApi(String heroName);
  Future<AgentModel?> getHeroByIdLocal(int id);
  Future<Map<String, List<AgentModel>>> sortedHeroesVillains();
  Future<void> deleteHero(int id);
  //Future<void> updateJsonWithHeroesList();
  //Future<void> loadHeroesFromJsonToHeroesList();
  //Future<AgentModel> updateHero(AgentModel updatedHero);
}