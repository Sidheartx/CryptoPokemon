pragma solidity >=0.5.0 <0.6.0;

import "./Pokemonattack.sol";
import "./erc721.sol";
import "./safemath.sol";

contract PokemonOwnership is PokemonAttack, ERC721 {

  using SafeMath for uint256;

  mapping (uint => address) PokemonApprovals;

  function balanceOf(address _owner) external view returns (uint256) {
    return ownerPokemonCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
    return PokemonToOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownerPokemonCount[_to] = ownerPokemonCount[_to].add(1);
    ownerPokemonCount[msg.sender] = ownerPokemonCount[msg.sender].sub(1);
    PokemonToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
      require (PokemonToOwner[_tokenId] == msg.sender || PokemonApprovals[_tokenId] == msg.sender);
      _transfer(_from, _to, _tokenId);
    }

  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
      PokemonApprovals[_tokenId] = _approved;
      emit Approval(msg.sender, _approved, _tokenId);
    }

}
