// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "../src/TimedToken.sol";

contract DeployTimedToken is Script {
    function run() public {
        // Recupera a chave privada do ambiente para implantação
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Inicia a transmissão de transações usando a chave privada do implantador
        vm.startBroadcast(deployerPrivateKey);

        // Implanta o contrato TimedToken
        TimedToken token = new TimedToken();

        // Registra o endereço do contrato implantado
        console.log("TimedToken implantado em:", address(token));

        // Verifica o REWARD_AMOUNT atual
        console.log("REWARD_AMOUNT atual:", token.REWARD_AMOUNT());

        // Verifica o REWARD_INTERVAL atual (deve ser 48 horas)
        console.log("REWARD_INTERVAL atual:", token.REWARD_INTERVAL());

        // Verifica o proprietário do contrato
        console.log("Proprietario do contrato:", token.owner());

        // Verifica o saldo total do contrato
        console.log("Saldo total do contrato:", token.balanceOf(address(token)));

        // Encerra a transmissão de transações
        vm.stopBroadcast();
    }
}