pragma solidity >=0.5.0 <0.6.0;

import "./Pokemonhelper.sol";

contract PokemonAttack is PokemonHelper {
  uint randNonce = 0;
  uint attackVictoryProbability = 70;

  function randMod(uint _modulus) internal returns(uint) {
    randNonce++;
    return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
  }

  function attack(uint _PokemonId, uint _targetId) external ownerOf(_PokemonId) {
    Pokemon storage myPokemon = Pokemons[_PokemonId];
    Pokemon storage enemyPokemon = Pokemons[_targetId];
    uint rand = randMod(100);
    if (rand <= attackVictoryProbability) {
      myPokemon.winCount++;
      myPokemon.level++;
      enemyPokemon.lossCount++;
      feedAndMultiply(_PokemonId, enemyPokemon.dna, "Pokemon");
    } else {
      myPokemon.lossCount++;
      enemyPokemon.winCount++;
      _triggerCooldown(myPokemon);
    }
  }
}