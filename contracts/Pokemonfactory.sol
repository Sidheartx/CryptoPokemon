pragma solidity >=0.5.0 <0.6.0;

contract PokemonFactory {

    event NewPokemon(uint pokemonId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Pokemon {
        string name;
        uint dna;
    }

    Pokemon[] public Pokemons;

    mapping (uint => address) public PokemonToOwner;
    mapping (address => uint) ownerPokemonCount;

    function _createPokemon(string memory _name, uint _dna) private {
        uint id = Pokemons.push(Pokemon(_name, _dna)) - 1;
        PokemonToOwner[id] = msg.sender;
        ownerPokemonCount[msg.sender]++;
        emit NewPokemon(id, _name, _dna);
    }

    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomPokemon(string memory _name) public {
        require(ownerPokemonCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createPokemon(_name, randDna);
    }

}
