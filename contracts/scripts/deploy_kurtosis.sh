#!/bin/bash
# NOTE: This script should be run through `just devnet-up` rather than directly.
kurtosis_port=$(kurtosis port print world-chain op-el-builder-1-world-chain-builder-op-node-op-kurtosis rpc)
BUILDER_SOCKET=$(echo "$kurtosis_port" | grep -o 'http://127.0.0.1:[0-9]*')
CHAIN_ID="2151908"

export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Safe EOA Signers
# Mnemonic: "test test test test test test test test test test test junk"
export SAFE_OWNER_0=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 # m/44'/60'/0'/0/0
export SAFE_OWNER_1=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d # m/44'/60'/0'/0/1
export SAFE_OWNER_2=0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a # m/44'/60'/0'/0/2
export SAFE_OWNER_3=0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6 # m/44'/60'/0'/0/3
export SAFE_OWNER_4=0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a # m/44'/60'/0'/0/4
export SAFE_OWNER_5=0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba # m/44'/60'/0'/0/5

# Deploys WorldID at: 0x5FbDB2315678afecb367f032d93F642f64180aa3
cast send --rpc-url $BUILDER_SOCKET \
    --private-key $PRIVATE_KEY \
    --create 0x60a060405262093a806000556040516100179061015e565b604051809103906000f080158015610033573d6000803e3d6000fd5b50600380546001600160a01b03929092166001600160a01b03199092169190911790556004805460ff60a01b1916600160a01b17905534801561007557600080fd5b5060405162002a0938038062002a098339810160408190526100969161016c565b806100aa816100e560201b6106481760201c565b6100d057604051630220cee360e61b815260ff8216600482015260240160405180910390fd5b60ff166080526100df3361010c565b50610196565b60006010602060ff8416821180159061010457508060ff168460ff1611155b949350505050565b600480546001600160a01b038381166001600160a01b0319831681179093556040519116919082907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a35050565b611ade8062000f2b83390190565b60006020828403121561017e57600080fd5b815160ff8116811461018f57600080fd5b9392505050565b608051610d79620001b2600039600061016a0152610d796000f3fe608060405234801561001057600080fd5b50600436106100df5760003560e01c8063b242e5341161008c578063d7b0fef111610066578063d7b0fef1146101df578063f1c621ee146101e7578063f2fde38b1461023a578063fbde929b1461024d57600080fd5b8063b242e534146101a6578063b354b37a146101b9578063c70aa727146101cc57600080fd5b80638da5cb5b116100bd5780638da5cb5b1461013b5780638e5cdd5014610163578063b0d690791461019457600080fd5b80630ee04629146100e4578063354ca1201461011e578063715018a614610133575b600080fd5b6004546101099074010000000000000000000000000000000000000000900460ff1681565b60405190151581526020015b60405180910390f35b61013161012c366004610b9c565b610260565b005b610131610317565b60045460405173ffffffffffffffffffffffffffffffffffffffff9091168152602001610115565b60405160ff7f0000000000000000000000000000000000000000000000000000000000000000168152602001610115565b6000545b604051908152602001610115565b6101316101b4366004610c11565b61032b565b6101316101c7366004610c4f565b6104aa565b6101316101da366004610c69565b61052a565b61019861053e565b6102196101f5366004610c69565b6002602052600090815260409020546fffffffffffffffffffffffffffffffff1681565b6040516fffffffffffffffffffffffffffffffff9091168152602001610115565b610131610248366004610c82565b610583565b61013161025b366004610c69565b610637565b6102698561066f565b60035460408051608081018252878152602081018690528082018790526060810185905290517f2357251100000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff909216916323572511916102e091859190600401610ccf565b60006040518083038186803b1580156102f857600080fd5b505afa15801561030c573d6000803e3d6000fd5b505050505050505050565b61031f610731565b6103296000610a02565b565b610333610731565b73ffffffffffffffffffffffffffffffffffffffff82166103db576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603260248201527f43726f7373446f6d61696e4f776e61626c65333a206e6577206f776e6572206960448201527f7320746865207a65726f2061646472657373000000000000000000000000000060648201526084015b60405180910390fd5b60006103fc60045473ffffffffffffffffffffffffffffffffffffffff1690565b905061040783610a02565b6004805483151574010000000000000000000000000000000000000000027fffffffffffffffffffffff00ffffffffffffffffffffffffffffffffffffffff90911617905560405173ffffffffffffffffffffffffffffffffffffffff80851691908316907f7fdc2a4b6eb39ec3363d710d188620bd1e97b3c434161f187b4d0dc0544faa589061049d90861515815260200190565b60405180910390a3505050565b6104b38561066f565b60035460408051608081018252878152602081018690528082018790526060810185905290517ff2457c8d00000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff9092169163f2457c8d916102e091859190600401610cf5565b610532610731565b61053b81610a79565b50565b600060015460000361057c576040517f5b8dabb700000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b5060015490565b61058b610731565b73ffffffffffffffffffffffffffffffffffffffff811661062e576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602660248201527f4f776e61626c653a206e6577206f776e657220697320746865207a65726f206160448201527f646472657373000000000000000000000000000000000000000000000000000060648201526084016103d2565b61053b81610a02565b61063f610731565b61053b81610ab4565b60006010602060ff8416821180159061066757508060ff168460ff1611155b949350505050565b600154810361067b5750565b6000818152600260205260408120546fffffffffffffffffffffffffffffffff16908190036106d6576040517fddae3b7100000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b6000546106f56fffffffffffffffffffffffffffffffff831642610d11565b111561072d576040517f3ae7359e00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b5050565b60045474010000000000000000000000000000000000000000900460ff1615610817573361077460045473ffffffffffffffffffffffffffffffffffffffff1690565b73ffffffffffffffffffffffffffffffffffffffff1614610329576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602c60248201527f43726f7373446f6d61696e4f776e61626c65333a2063616c6c6572206973206e60448201527f6f7420746865206f776e6572000000000000000000000000000000000000000060648201526084016103d2565b7342000000000000000000000000000000000000073381146108bb576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152603060248201527f43726f7373446f6d61696e4f776e61626c65333a2063616c6c6572206973206e60448201527f6f7420746865206d657373656e6765720000000000000000000000000000000060648201526084016103d2565b8073ffffffffffffffffffffffffffffffffffffffff16636e296e456040518163ffffffff1660e01b8152600401602060405180830381865afa158015610906573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061092a9190610d4f565b73ffffffffffffffffffffffffffffffffffffffff1661095f60045473ffffffffffffffffffffffffffffffffffffffff1690565b73ffffffffffffffffffffffffffffffffffffffff161461053b576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602c60248201527f43726f7373446f6d61696e4f776e61626c65333a2063616c6c6572206973206e60448201527f6f7420746865206f776e6572000000000000000000000000000000000000000060648201526084016103d2565b6004805473ffffffffffffffffffffffffffffffffffffffff8381167fffffffffffffffffffffffff0000000000000000000000000000000000000000831681179093556040519116919082907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a35050565b60008190556040518181527f147b815b6a3a8dd5d49310410e089f6b5e9f3782e944772edc938c8bb48ef1219060200160405180910390a150565b6000818152600260205260409020546fffffffffffffffffffffffffffffffff168015610b0d576040517f6650c4d100000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b600182905560008281526002602090815260409182902080547fffffffffffffffffffffffffffffffff0000000000000000000000000000000016426fffffffffffffffffffffffffffffffff8116918217909255835186815292830152917fe97c89cbb137505b36f55ebfc9732fd6c4c73ff43d49db239fc25f6e7a534145910160405180910390a1505050565b6000806000806000610180808789031215610bb657600080fd5b86359550602087013594506040870135935060608701359250878188011115610bde57600080fd5b506080860190509295509295909350565b73ffffffffffffffffffffffffffffffffffffffff8116811461053b57600080fd5b60008060408385031215610c2457600080fd5b8235610c2f81610bef565b915060208301358015158114610c4457600080fd5b809150509250929050565b6000806000806000610100808789031215610bb657600080fd5b600060208284031215610c7b57600080fd5b5035919050565b600060208284031215610c9457600080fd5b8135610c9f81610bef565b9392505050565b8060005b6004811015610cc9578151845260209384019390910190600101610caa565b50505050565b6101808101610100808584376000908301908152610ced8185610ca6565b509392505050565b610100810160808483376080820160008152610ced8185610ca6565b600082821015610d4a577f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b500390565b600060208284031215610d6157600080fd5b8151610c9f81610bef56fea164736f6c634300080f000a608060405234801561001057600080fd5b50611abe806100206000396000f3fe608060405234801561001057600080fd5b50600436106100415760003560e01c8063235725111461004657806344f636921461005b578063f2457c8d14610084575b600080fd5b61005961005436600461198b565b610097565b005b61006e6100693660046119c2565b61032f565b60405161007b91906119e6565b60405180910390f35b610059610092366004611a17565b61038c565b6000806100a3836106c2565b9150915060006040516101008682377f168e4fddac50a40d5bcff39c7fa9207cd368444c0c01a86690a6645b52f3aa1f6101008201527f2139a256456825daa623957c4f2ea1a0d26f135769e450759142a7159b0a44766101208201527f07859424108de88bfbe5c80a19c0e80ba35fda4383d3fd125305dd04b4c08fe46101408201527f142ad7a93ca0c554a9f0303059e5a24e85400004a730598bd423b0090f4b3d4a6101608201527f2d4d9aa7e302d9df41749d5507949d05dbea33fbb16c643b22f599a2be6df2e26101808201527f14bedd503c37ceb061d8ec60209fe345ce89830a19230301f076caff004d19266101a08201527f0967032fcbf776d1afc985f88877f182d38480a653f2decaa9794cbc3bf3060c6101c08201527f0e187847ad4c798374d0d6732bf501847dd68bc0e071241e0213bc7fc13db7ab6101e08201527e1752a100a72fdf1e5a5d6ea841cc20ec838bccfcf7bd559e79f1c9c759b6a06102008201527f192a8cc13cd9f762871f21e43451c6ca9eeab2cb2987c4e366a185c25dac2e7f61022082015283610240820152826102608201527f198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c26102808201527f1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed6102a08201527f275dc4a288d1afb3cbb1ac09187524c7db36395df7be3b99e673b13a075a65ec6102c08201527f1d9befcd05a5323e6da4d435f3b617cdb3af83285c2df711ef39c01571827f9d6102e08201526020816103008360085afa905116905080610328576040517f7fcdd1f400000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b5050505050565b61033761190d565b61034a82358360015b60200201356109c8565b81526103686060830135604084013560a08501356080860135610b67565b6020830152604082015261038260c0830135836007610340565b6060820152919050565b60008061039f84825b6020020135611041565b909250905060008080806103bb604089013560208a0135611165565b929650909450925090506000806103d38a6003610395565b915091506000806103e38b6106c2565b915091506103ef61192b565b8a8152602081018a905260408101889052606081018990526080810186905260a0810187905260c0810185905260e081018490527f168e4fddac50a40d5bcff39c7fa9207cd368444c0c01a86690a6645b52f3aa1f6101008201527f2139a256456825daa623957c4f2ea1a0d26f135769e450759142a7159b0a44766101208201527f07859424108de88bfbe5c80a19c0e80ba35fda4383d3fd125305dd04b4c08fe46101408201527f142ad7a93ca0c554a9f0303059e5a24e85400004a730598bd423b0090f4b3d4a6101608201527f2d4d9aa7e302d9df41749d5507949d05dbea33fbb16c643b22f599a2be6df2e26101808201527f14bedd503c37ceb061d8ec60209fe345ce89830a19230301f076caff004d19266101a08201527f0967032fcbf776d1afc985f88877f182d38480a653f2decaa9794cbc3bf3060c6101c08201527f0e187847ad4c798374d0d6732bf501847dd68bc0e071241e0213bc7fc13db7ab6101e08201527e1752a100a72fdf1e5a5d6ea841cc20ec838bccfcf7bd559e79f1c9c759b6a06102008201527f192a8cc13cd9f762871f21e43451c6ca9eeab2cb2987c4e366a185c25dac2e7f610220820152610240810183905261026081018290527f198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c26102808201527f1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed6102a08201527f275dc4a288d1afb3cbb1ac09187524c7db36395df7be3b99e673b13a075a65ec6102c08201527f1d9befcd05a5323e6da4d435f3b617cdb3af83285c2df711ef39c01571827f9d6102e0820152600061065e61194a565b6020816103008560085afa915081158061067a57508051600114155b156106b1576040517f7fcdd1f400000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b505050505050505050505050505050565b6000806000600190506040516040810160007f0335f514c2acb9b255aae85514122267cd7d16e374c6231a2c34417d3449125483527f07fa1580c1cc3ed4f6d660c6f60f86afedd8a12fb90b2e8ed4f7e310c88b97f760208401527f20b781dd0db3b7980a4b3814128c86e597e1442d0fc9eb7f932a5229494d6b7982527f17d1cef436eb2f665670c7b34854e62c227043a7b111a539c0295518bbab3ca96020830152863590508060408301527f30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f000000181108416935060408260608460075afa8416935060408360808560065afa841693507f260945445b4205f874ab7e203a18240e51c9d3c896ea300d40132b1c2f50299a82527f11087a8b76b0f957e1c482c909302916795f811a06866059e403689c01c903fb6020830152602087013590508060408301527f30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f000000181108416935060408260608460075afa8416935060408360808560065afa841693507f11d20fd81c0e5cf48ba1469ccb8ac99dcdc7cf746a6e70762a939d63dcc52dbf82527f2d447c5f134eff527d7bcaace88b3842c42b800d8dc049e0a6e72f5efc14293d6020830152604087013590508060408301527f30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f000000181108416935060408260608460075afa8416935060408360808560065afa841693507f107cd54a1606a6a873bed4c1b76af48975e66dcf6c127b4c799ad4fdd230b87c82527f1a51b81f6c07725ebcc56ebb1c482b99340eaa9bcb86cc09aed6f58a28e530b66020830152606087013590508060408301527f30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f00000018110841693505060408160608360075afa831692505060408160808360065afa815160209092015191945090925016806109c2576040517fa54f8e2700000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b50915091565b60007f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4783101580610a1957507f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478210155b15610a50576040517f7fcdd1f400000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b82158015610a5c575081155b15610a6957506000610b61565b6000610ade7f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4760037f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47877f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47898a0909086114b0565b9050808303610af3575050600182901b610b61565b7f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478082068103068303610b2d575050600182811b17610b61565b6040517f7fcdd1f400000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b505b92915050565b6000807f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4786101580610bb957507f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478510155b80610be457507f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478410155b80610c0f57507f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478310155b15610c46576040517f7fcdd1f400000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b82848688171717600003610c5f57506000905080611038565b600080807f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47610caf60037f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47611a73565b7f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478a8c0909905060007f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478a7f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478c8d0909905060007f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478a7f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478c8d090990507f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47807f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478c860984087f2b149d40ceb8aaae81be18991be06ac3b5b4c5e559dbefa33267e6dc24a138e5089450610e707f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47807f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478e870984087f2fcd3ac2a640a154eb23960892a85a68f031ca0c8344b23a577dcf1052b9e775087f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd479081900681030690565b9350505050600080610ef77f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4780610ea957610ea9611a44565b7f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478586097f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47878809086114b0565b9050610f687f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd477f183227397098d014dc2822db40c0ac2ecbc0b548b438e5469e10460b6c3e7ea47f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478488080961153f565b15915050610f7783838361159b565b90935091508683148015610f8a57508186145b15610fb45780610f9b576000610f9e565b60025b60ff1660028a901b176000179450879350611034565b7f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478084068103068714801561100e57507f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4780830681030686145b15610b2d578061101f576000611022565b60025b60ff1660028a901b1760011794508793505b5050505b94509492505050565b6000808260000361105757506000928392509050565b600183811c9250808416147f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4783106110bb576040517f7fcdd1f400000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b61112e7f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4760037f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47867f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4788890909086114b0565b915080156109c2577f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47808306810306915050915091565b600080808085158015611176575084155b1561118c575060009250829150819050806114a7565b600286811c945085935060018088161490808816147f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47861015806111f057507f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478510155b15611227576040517f7fcdd1f400000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b60007f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4761127560037f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47611a73565b7f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47888a0909905060007f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47887f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478a8b0909905060007f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47887f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478a8b090990507f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47807f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478a860984087f2b149d40ceb8aaae81be18991be06ac3b5b4c5e559dbefa33267e6dc24a138e50896506114367f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47807f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478c870984087f2fcd3ac2a640a154eb23960892a85a68f031ca0c8344b23a577dcf1052b9e775087f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd479081900681030690565b955061144387878661159b565b909750955084156114a1577f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4780880681030696507f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4780870681030695505b50505050505b92959194509250565b60006114dc827f0c19139cb84c680a6e14116da060561765e05aa45a1c72a34f082305b61f3f526117f2565b9050817f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478283091461153a576040517f7fcdd1f400000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b919050565b60008061156c837f0c19139cb84c680a6e14116da060561765e05aa45a1c72a34f082305b61f3f526117f2565b9050827f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47828309149392505050565b600080806115f17f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47808788097f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47898a09086114b0565b90508315611622577f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47908190068103065b6116917f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd477f183227397098d014dc2822db40c0ac2ecbc0b548b438e5469e10460b6c3e7ea47f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47848a08096114b0565b92507f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd476116e17f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4760028609611882565b860991507f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd476117587f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd478485097f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd479081900681030690565b7f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4785860908861415806117b257507f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47808385096002098514155b156117e9576040517f7fcdd1f400000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b50935093915050565b60008060405160208152602080820152602060408201528460608201528360808201527f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4760a082015260208160c08360055afa90519250905080610b5f576040517f7fcdd1f400000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b60006118ae827f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd456117f2565b90507f30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd4781830960011461153a576040517f7fcdd1f400000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b60405180608001604052806004906020820280368337509192915050565b6040518061030001604052806018906020820280368337509192915050565b60405180602001604052806001906020820280368337509192915050565b806101008101831015610b6157600080fd5b8060808101831015610b6157600080fd5b600080610180838503121561199f57600080fd5b6119a98484611968565b91506119b984610100850161197a565b90509250929050565b600061010082840312156119d557600080fd5b6119df8383611968565b9392505050565b60808101818360005b6004811015611a0e5781518352602092830192909101906001016119ef565b50505092915050565b6000806101008385031215611a2b57600080fd5b611a35848461197a565b91506119b9846080850161197a565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601260045260246000fd5b600082821015611aac577f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b50039056fea164736f6c634300080f000a000000000000000000000000000000000000000000000000000000000000001e "constructor(uint8 _treeDepth)" 30

forge script scripts/DeployDevnet.s.sol:DeployDevnet --rpc-url $BUILDER_SOCKET --chain $CHAIN_ID --broadcast