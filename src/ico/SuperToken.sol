pragma solidity ^0.4.0;

import './IERC20.sol';
import './SafeMath.sol';

contract SuperToken is IERC20 {

    using SafeMath for uint256;

    /**
    * Количество выпущенных монет ST
    **/
    uint public totalSupply = 0;

    /**
    * Сокращенное название монеты
    **/
    string public constant symbol = "ST";

    /**
    * Полное название монеты
    **/
    string public constant name = "Super Token";

    /**
    * Переменная, которая показывает на сколько монета может дробиться
    * 18 - также, как и у эфира
    **/
    uint8 public constant decimals = 18;

    /**
    * 1 ether = 100 Super Token
    **/
    uint256 public constant RATE = 100;

    /**
    * Адресс владельца контракта
    **/
    address public owner;

    /**
    * Переменная, в которой хранится баланс по каждому кошельку юзера
    **/
    mapping(address => uint256) balances;

    /**
    * Переменная, в которой хранится информация "кто разрешил кому передать столько то токенов"
    **/
    mapping(address => mapping(address => uint256)) allowed;

    /**
    * Модификатор, разрешает выполнять функцию только создателю контракта
    **/
    modifier allowOnlyOwner() {
        require(owner == msg.sender);
        _;
    }

    /**
    * Калбек, разрешает закидывать ефиры на адресс контракта
    **/
    function () payable {
        createTokens();
    }

    /**
    * Конструктор, запись адреса создателя контракта в переменную owner
    **/
    function SuperToken() {
        owner = msg.sender;
    }

    /**
    * "Убить" контракт и передать все эфиры, которые есть на счете у контракта на адресс создателя контракта
    **/
    function kill() allowOnlyOwner {
        selfdestruct(owner);
    }

    /**
    * Функция, которая "конвертирует" ефиры в супер токены. Любой может "закинуть" эфиры в контракт и получить супер токены
    **/
    function createTokens() payable {
        require(msg.value > 0);

        uint256 tokens = msg.value.mul(RATE);

        balances[msg.sender] = balances[msg.sender].add(tokens);

        totalSupply = totalSupply.add(tokens);

        owner.transfer(msg.value);
    }

    /**
    * Функция позволяет получить баланс кошелька (супер токены)
    **/
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /**
    * Функция позволяет передать супер токены на адресс другого кошелька
    **/
    function transfer(address _to, uint256 _value) returns (bool success) {
        require(
            balances[msg.sender] >= _value
            && _value > 0
        );

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
    * Функция позволяет передать супер токены с адресса другого кошелька, если это разрешено (разрешенна определенная сумма), на адресс любого кошелька
    **/
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(
            allowed[_from][msg.sender] >= _value
            && balances[_from] >= _value
            && _value > 0
        );

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        Transfer(_from, _to, _value);

        return true;
    }

    /**
    * Функция разрешает передавать токены с аккаунта1 (того, кто вызывает функцию) аккаунтом2
    * Разрешается определенная сумма _value
    **/
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    /**
    * Функция возвращает то, сколько _spender может потратить супер токенов с адресса _owner
    **/
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
    * Событие - успшеная транзакция (передача супер токена с одного аккаунта на другой)
    **/
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /**
    * Событие - разрешение передачи токены с аккаунта1 аккаунтом2
    **/
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}