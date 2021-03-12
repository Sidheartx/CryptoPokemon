const CryptoPokemons = artifacts.require("CryptoPokemons");
const utils = require("./helpers/utils");
const time = require("./helpers/time");
var expect = require('chai').expect;
const PokemonNames = ["Pokemon 1", "Pokemon 2"];
contract("CryptoPokemons", (accounts) => {
    let [alice, bob] = accounts;
    let contractInstance;
    beforeEach(async () => {
        contractInstance = await CryptoPokemons.new();
    });
    it("should be able to create a new Pokemon", async () => {
        const result = await contractInstance.createRandomPokemon(PokemonNames[0], {from: alice});
        
        expect(result.receipt.status).to.equal(true);
        expect(result.logs[0].args.name).to.equal(PokemonNames[0]);
    })
    it("should not allow two Pokemons", async () => {
        await contractInstance.createRandomPokemon(PokemonNames[0], {from: alice});
        await utils.shouldThrow(contractInstance.createRandomPokemon(PokemonNames[1], {from: alice}));
    })
    context("with the single-step transfer scenario", async () => {
        it("should transfer a Pokemon", async () => {
            const result = await contractInstance.createRandomPokemon(PokemonNames[0], {from: alice});
            const PokemonId = result.logs[0].args.PokemonId.toNumber();
            await contractInstance.transferFrom(alice, bob, PokemonId, {from: alice});
            const newOwner = await contractInstance.ownerOf(PokemonId);
            expect(newOwner).to.equal(bob);
            
        })
    })
    context("with the two-step transfer scenario", async () => {
        it("should approve and then transfer a Pokemon when the approved address calls transferFrom", async () => {
            const result = await contractInstance.createRandomPokemon(PokemonNames[0], {from: alice});
            const PokemonId = result.logs[0].args.PokemonId.toNumber();
            await contractInstance.approve(bob, PokemonId, {from: alice});
            await contractInstance.transferFrom(alice, bob, PokemonId, {from: bob});
            const newOwner = await contractInstance.ownerOf(PokemonId);
            expect(newOwner).to.equal(bob);
            
        })
        it("should approve and then transfer a Pokemon when the owner calls transferFrom", async () => {
            const result = await contractInstance.createRandomPokemon(PokemonNames[0], {from: alice});
            const PokemonId = result.logs[0].args.PokemonId.toNumber();
            await contractInstance.approve(bob, PokemonId, {from: alice});
            await contractInstance.transferFrom(alice, bob, PokemonId, {from: alice});
            const newOwner = await contractInstance.ownerOf(PokemonId);
            expect(newOwner).to.equal(bob);
         })
    })
    it("Pokemons should be able to attack another Pokemon", async () => {
        let result;
        result = await contractInstance.createRandomPokemon(PokemonNames[0], {from: alice});
        const firstPokemonId = result.logs[0].args.PokemonId.toNumber();
        result = await contractInstance.createRandomPokemon(PokemonNames[1], {from: bob});
        const secondPokemonId = result.logs[0].args.PokemonId.toNumber();
        await time.increase(time.duration.days(1));
        await contractInstance.attack(firstPokemonId, secondPokemonId, {from: alice});
        expect(result.receipt.status).to.equal(true);
       
    })
})
