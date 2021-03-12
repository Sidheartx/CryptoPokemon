pragma solidity >=0.5.0 <0.6.0;

import "./Pokemonfactory.sol";
import "./ownable.sol";

contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract PokemonFeeding is PokemonFactory, Ownable {

  KittyInterface kittyContract;

  function setKittyContractAddress(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

  function _triggerCooldown(Pokemon storage _Pokemon) internal {
    _Pokemon.readyTime = uint32(now + cooldownTime);
  }

  function _isReady(Pokemon storage _Pokemon) internal view returns (bool) {
      return (_Pokemon.readyTime <= now);
  }

  function feedAndMultiply(uint _PokemonId, uint _targetDna, string memory _species) internal {
    require(msg.sender == PokemonToOwner[_PokemonId]);
    Pokemon storage myPokemon = Pokemons[_PokemonId];
    require(_isReady(myPokemon));
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myPokemon.dna + _targetDna) / 2;
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createPokemon("NoName", newDna);
    _triggerCooldown(myPokemon);
  }

  function feedOnKitty(uint _PokemonId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_PokemonId, kittyDna, "kitty");
  }
}
