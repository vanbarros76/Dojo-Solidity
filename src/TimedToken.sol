// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;


contract TimedToken {
    string public name = "TimeToken"; // Nome do token
    string public symbol = "TTK"; // Simbolo do token
    uint8 public constant decimals = 18; // Decimais do token
    uint256 public constant TOTAL_SUPPLY = 100000 * 10** 18; // Quantidade total de tokens com decimais
    uint256 public REWARD_AMOUNT = 1 * 10**18; // Quantidade de tokens que o reward vai dar
    uint256 public REWARD_INTERVAL = 48 hours; // Periodo de tempo que o reward vai dar

    // Saldo de cada endereço, fundamental em contratos ERC20 para rastrear e gerenciar os saldos 
    // dos usuários de forma eficiente e transparente.
    mapping(address => uint256) public balanceOf; 

    // Mapeamento do tempo de próxima reivindicação para cada endereço; timestamp
    mapping(address => uint256) public nextClaimTime;

    address public owner; // endereço do proprietário do contrato

    // evento, usado em ERC20, que é emitido sempre que uma transferência de tokens ocorre
    event Transfer(address indexed from, address indexed to, uint256 value);

    // evento que é emitido quando o proprietário do contrato é transferido para um novo endereço
    event OwnerchipTransferred(address indexed previousOwner, address indexed newOwner);

     // ReentrancyGuard
    bool private _notEntered;

    modifier nonReentrant() {
        // Na primeira chamada para nonReentrant, _notEntered será verdadeiro
        require(_notEntered, "Reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Construtor do contrato, que inicializa o saldo do contrato com a quantidade total de tokens
    // Isso significa que, ao implantar o contrato, todos os tokens criados inicialmente ficam 
    //disponíveis no saldo do contrato, permitindo que o contrato controle e distribua os tokens 
    //posteriormente, por meio de funções como transfer ou mint.
    constructor() {
        owner = msg.sender;
        balanceOf[address(this)] = TOTAL_SUPPLY;
        emit Transfer(address(0), address(this), TOTAL_SUPPLY);
        _notEntered = true;
    }

    function claimTokens() public {
        // Verifica se o tempo atual é maior ou igual ao tempo da próxima reivindicação
        require(block.timestamp >= nextClaimTime[msg.sender], "Claim not available yet"); 

        // Verifica se o saldo do contrato é maior ou igual à quantidade de tokens que o reward vai dar
        require(balanceOf[address(this)] >= REWARD_AMOUNT, "Insufficient tokens in contract");

        // Atualiza o tempo da próxima reivindicação para o endereço do usuário
        nextClaimTime[msg.sender] = block.timestamp + REWARD_INTERVAL;

        // Subtrai a quantidade de tokens que o reward vai dar do saldo do contrato
        balanceOf[address(this)] -= REWARD_AMOUNT;

        // Adiciona a quantidade de tokens que o reward vai dar ao saldo do usuário
        balanceOf[msg.sender] += REWARD_AMOUNT;

        // Emite um evento Transfer para registrar a transferência de tokens
        emit Transfer(address(this), msg.sender, REWARD_AMOUNT);
    }

    function setRewardAmout(uint256 _newAmount) public onlyOwner { // Função para definir a quantidade de tokens que o reward vai dar
        REWARD_AMOUNT = _newAmount; // Atualiza a quantidade de tokens que o reward vai dar
    }

    function setRewardInterval(uint256 _newInterval) public onlyOwner { // Função para definir o periodo de tempo que o reward vai dar
        REWARD_INTERVAL = _newInterval; // Atualiza o periodo de tempo que o reward vai dar
    }

    function transferOwnership(address _newOwner) public onlyOwner { // Função para transferir a propriedade do contrato para um novo endereço
        require(_newOwner != address(0), "Invalid address"); // Verifica se o novo proprietário não é um endereço inválido
        emit OwnerchipTransferred(owner, _newOwner); // Emite um evento OwnerchipTransferred para registrar a transferência do proprietário 
        owner = _newOwner; // Atualiza o proprietário do contrato para o novo endereço
    }  
        
}
