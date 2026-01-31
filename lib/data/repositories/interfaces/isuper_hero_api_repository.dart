import 'package:flutter_herodex3000/barrel_files/models.dart';

abstract interface class ISuperHeroApiRepository{
  
  Future<List<AgentModel>> getHeroByName(String name);
}