import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/barrel_files/interfaces.dart';
import 'package:flutter_herodex3000/barrel_files/factories.dart';
import 'package:flutter_herodex3000/barrel_files/repositories.dart';

class HeroDataManager implements IAgentDataManager{
  static final clientFactory = HttpClientFactory();
  final SuperHeroApiRepository apiHeroRepo;
  final List<AgentModel> _heroesList = [];

  // Private constructor for Singleton
  HeroDataManager._internal({required this.apiHeroRepo});

  // Single static instance
  static HeroDataManager? _instance;

  // Factory only creates once
  factory HeroDataManager({SuperHeroApiRepository? apiRepo}){
    _instance ??= HeroDataManager._internal(
      apiHeroRepo: apiRepo ?? SuperHeroApiRepository(clientFactory: clientFactory),
    );
    return _instance!;
  }

  
  // Function to create new hero/villian with check for if the name already exist and wont create a duplicate
  @override
  Future<AgentModel?> createHero(AgentModel hero) async {

    try {
      final heroAlreadyExists = _heroesList.any((h) => h.name.toLowerCase() == hero.name.toLowerCase());

      if(heroAlreadyExists){     
        return null;
      }

      int newId = _heroesList.isEmpty 
                  ? 1 
                  : _heroesList.last.heroId + 1; // Auto-increment ID based on the last hero in the list

      final newHero = AgentModel(
        heroId: newId,
        name: hero.name,
        powerstats: hero.powerstats,
        biography: hero.biography,
        appearance: hero.appearance,
        image: hero.image,
        work: hero.work,
        connections: hero.connections,
      );
      _heroesList.add(newHero);

      return newHero;      
    } catch (e) {
        throw Exception("❌ Misslyckades att spara hjälte/skurk: $e");
    }

  }
  
  // Function to get all heroes/villians in the local list _heroesList
  @override
  Future<List<AgentModel>> getAllHeroesLocal() async {
    return _heroesList;
  }
  
  // Function to get hero/villian by name in the local list _heroesList
  @override
  Future<List<AgentModel>> getHeroByNameLocal(String heroName) async {
    final search = heroName.toLowerCase();
    return _heroesList
        .where((h) => h.name.toLowerCase().contains(search))
        .toList();
  }
  
  // Function to get hero/villian by name from the api https://superheroapi.com/
  @override
  Future<List<AgentModel>> getHeroByNameApi(String heroName) async {
    return apiHeroRepo.getHeroByName(heroName);
  }
  
  // Function to delete hero/villian from local list _heroesList
  @override
  Future<void> deleteHero(int id) async {
    _heroesList.removeWhere((h) => h.heroId == id);
  }
  
  // Function to sort heroes and villians ans return Map with them sorted
  @override
  Future<Map<String, List<AgentModel>>> sortedHeroesVillains() async {
    final heroes = _heroesList
        .where((h) => h.biography.alignment.toLowerCase() == "good")
        .toList();

    final villains = _heroesList
        .where((v) => v.biography.alignment.toLowerCase() == "bad")
        .toList();

    final neutrals = _heroesList
        .where((v) => v.biography.alignment.toLowerCase() == "neutral")
        .toList();
    
    return {
      "heroes": heroes,
      "villains": villains,
      "neutrals" : neutrals
    };
  }
  
  // Function to load heroes/villians from the local json file to the _heroesList
  // @override
  // Future<int> loadHeroesFromJsonToHeroesList() async {
  //   try {
  //     final parsedJsonHeroes = await localFileRepo.readLocalHeroFile();

  //     _heroesList
  //       ..clear()
  //       ..addAll(parsedJsonHeroes);

  //     return _heroesList.length;
  //   } catch (e) {
  //     throw Exception("❌ Misslyckades att ladda hjältar och skurkar: $e");
  //   }
  // }
  
  // Function to get a hero/villian by Id in the local list _heroesList
  @override
  Future<AgentModel?> getHeroByIdLocal(int id) async {
    try {
      var hero = _heroesList.firstWhere((h) => h.heroId == id);
      return hero;
    } catch (_) {
      return null;
    }
  }
  
  // Function to update the local json file with the local list _heroesList
  // @override
  // Future<void> updateJsonWithHeroesList() async {
  //   try {
  //     await localFileRepo.updateLocalHeroFile(_heroesList);
  //   } catch (e) {
  //     throw Exception("❌ Misslyckades att spara hjältar och skurkar: $e");
  //   }
  // }


  // Update hero prepered function
  // @override
  // Future<AgentModel> updateHero(AgentModel updatedHero) async {
  //   final index = _heroesList.indexWhere((h) => h.heroId == updatedHero.heroId);
  //   if (index == -1) {
  //     throw Exception("Hero with ID ${updatedHero.heroId} not found");
  //   }
  //   _heroesList[index] = updatedHero;
  //   return updatedHero;
  // }

}