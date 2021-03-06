const assert = require ('assert');              // утверждения
const ganache = require ('ganache-cli');        // тестовая сеть
const Web3 = require ('web3');                  // библиотека для подключения к ефириуму
//const web3 = new Web3(ganache.provider());      // настройка провайдера


require('events').EventEmitter.defaultMaxListeners = 0;


const compiledContract = require('../build/Crowdsale.json');

const compiledToken = require('../build/CRYPTToken.json');

let accounts;
let contractAddress;
//console.log(Date());


describe('Укороченная серия тестов для проверки доп. функций контракта...', () => {
    let web3 = new Web3(ganache.provider());      // настройка провайдера

    it('Разворачиваем контракт для тестирования...', async () => {

        accounts = await web3.eth.getAccounts();
        contract = await new web3.eth.Contract(JSON.parse(compiledContract.interface))
            .deploy({ data: compiledContract.bytecode })
            .send({ from: accounts[0], gas: '6000000'});
    });

    it('Получаем стадию контракта, по умолчанию это init', async () => {
        const myState = await contract.methods.currentState().call({
            from: accounts[3],
            gas: "1000000"
        });
        assert(myState == 0);
    });

    it('Запускаем Pre-Sale от собственника - ОК', async () => {
        try {
            await contract.methods.startPreSale().send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
        }

    });

    it('Проверяем state - должен быть Pre-sale', async () => {
        const myState2 = await contract.methods.currentState().call({
            from: accounts[0],
            gas: "1000000"
        });
        assert(myState2 == 1);
    });

    it('increase time for 5 days', async () => {
        const myVal = await new Promise((resolve, reject) =>
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [60 * 60 * 24 * 5],
            id: new Date().getTime()
        }, (error, result) => error ? reject(error) : resolve(result.result))
    );
    });

    it('Переводим 20 эфиров на контракт - должен принять...', async () => {
        try {
            let funders = await contract.methods.AddBalanceContract().send({
                    from: accounts[5],
                    value: 20*10**18,
                    gas: '1000000'
                });
            assert(true);
        } catch (error) {
            assert(false);
            console.log(error);
        }
    });

    it('increase time for 4 days - last day of Per-Sale', async () => {
        const myVal = await new Promise((resolve, reject) =>
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [60 * 60 * 24 * 4],
            id: new Date().getTime()
        }, (error, result) => error ? reject(error) : resolve(result.result))
    );
    });    

    it('Переводим 20 эфиров на контракт - должен принять...', async () => {
        try {
            let funders = await contract.methods.AddBalanceContract().send({
                    from: accounts[6],
                    value: 20*10**18,
                    gas: '1000000'
                });
            assert(true);
        } catch (error) {
            assert(false);
            console.log(error);
        }
    });

    it('increase time for 1 days - Pre-Sale stage is closed', async () => {
        const myVal = await new Promise((resolve, reject) =>
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [60 * 60 * 24 * 4],
            id: new Date().getTime()
        }, (error, result) => error ? reject(error) : resolve(result.result))
    );
    });    

    it('Проверка баланса на accounts[7] - более 25 эфиров...', async () => {
        accBalance = web3.utils.fromWei(await web3.eth.getBalance(accounts[7]), 'ether');
        assert(accBalance > 25);
        //console.log("Balance of accounts[7]: ", accBalance);
    });


    it('Переводим 20 эфиров на контракт от account[7] - должен отбить...', async () => {
        try {
            let funders = await contract.methods.AddBalanceContract().send({
                    from: accounts[7],
                    value: 20*10**18,
                    gas: '1000000'
                });
            assert(false);
        } catch (error) {
            assert(error);
        }
    });

    it('Проверяем state - должен быть все еще Pre-sale но на паузе...', async () => {
        const myState2 = await contract.methods.currentState().call({
            from: accounts[0],
            gas: "1000000"
        });
        assert(myState2 == 1);
    });

    it('increase time for 30 days...', async () => {
        const myVal = await new Promise((resolve, reject) =>
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [60 * 60 * 24 * 30],
            id: new Date().getTime()
        }, (error, result) => error ? reject(error) : resolve(result.result))
    );
    });    

    it('Переводим 20 эфиров на контракт от account[7] - должен сменить stage и принять...', async () => {
        try {
            let funders = await contract.methods.AddBalanceContract().send({
                    from: accounts[7],
                    value: 20*10**18,
                    gas: '1000000'
                });
            assert(true);
        } catch (error) {
            assert(false);
        }
    });

    it('Проверяем state - должен быть PreICO...', async () => {
        const myState2 = await contract.methods.currentState().call({
            from: accounts[0],
            gas: "1000000"
        });
        assert(myState2 == 2);
    });

    it('Проверка токенов на счетe 9 должно быть 0...', async () => {
        let tokenBalance = await contract.methods.getBalanceTokens(accounts[9]).call();
        assert(tokenBalance == 0);
        //console.log(tokenBalance / (10**18));
    });


    it('Переводим 1 эфир на контракт от account[9] - должен принять...', async () => {
        try {
            let funders = await contract.methods.AddBalanceContract().send({
                    from: accounts[9],
                    value: 1*10**18,
                    gas: '1000000'
                });
            assert(true);
        } catch (error) {
            assert(false);
        }
    });

    it('Проверка токенов на счетe 9 должно быть 5000 + 10% = 5500...', async () => {
        let tokenBalance = await contract.methods.getBalanceTokens(accounts[9]).call();
        assert(tokenBalance == 5500 * (10**18));
        //console.log(tokenBalance / (10**18));
    });

    it('Проверка баланса на accounts[9] - более 20 эфиров...', async () => {
        accBalance = web3.utils.fromWei(await web3.eth.getBalance(accounts[9]), 'ether');
        assert(accBalance > 20);
        //console.log("Balance of accounts[9]: ", accBalance);
    });

    //it('Проверка колва проданных токенов...', async () => {
    //    accBalance = web3.utils.fromWei(await contract.methods.soldTokens().call(), 'ether');
    //    //assert(accBalance > 20);
    //    console.log("soldTokens: ", accBalance);
    //});

    it('Переводим 15 эфиров на контракт от account[9] - должен принять...', async () => {
        try {
            let funders = await contract.methods.AddBalanceContract().send({
                    from: accounts[9],
                    value: 15*10**18,
                    gas: '1000000'
                });
            assert(true);
        } catch (error) {
            assert(false);
        }
    });

    it('Переводим 5 эфир на контракт от account[9] - должен отбить, тк сумма будет 21 при макс. 20...', async () => {
        try {
            let funders = await contract.methods.AddBalanceContract().send({
                    from: accounts[9],
                    value: 5*10**18,
                    gas: '1000000'
                });
            assert(false);
        } catch (error) {
            assert(error);
        }
    });

    it('Переводим 4 эфира на контракт от account[9] - должен принять, тк сумма будет 20 при макс. 20...', async () => {
        try {
            let funders = await contract.methods.AddBalanceContract().send({
                    from: accounts[9],
                    value: 4*10**18,
                    gas: '1000000'
                });
            assert(true);
        } catch (error) {
            assert(false);
        }
    });


    it('increase time for 15 days - PreICO is closed...', async () => {
        const myVal = await new Promise((resolve, reject) =>
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [60 * 60 * 24 * 30],
            id: new Date().getTime()
        }, (error, result) => error ? reject(error) : resolve(result.result))
    );
    }); 

    it('Переводим 1 эфир на контракт от account[9] - должен отбить...', async () => {
        try {
            let funders = await contract.methods.AddBalanceContract().send({
                    from: accounts[9],
                    value: 1*10**18,
                    gas: '1000000'
                });
            assert(false);
        } catch (error) {
            assert(error);
        }
    });

    it('increase time for 30 days - pause is passed...', async () => {
        const myVal = await new Promise((resolve, reject) =>
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [60 * 60 * 24 * 30],
            id: new Date().getTime()
        }, (error, result) => error ? reject(error) : resolve(result.result))
    );
    }); 

    it('Переводим 1 эфир на контракт от account[9] - должен сменить stage и принять...', async () => {
        try {
            let funders = await contract.methods.AddBalanceContract().send({
                    from: accounts[9],
                    value: 1*10**18,
                    gas: '1000000'
                });
            assert(true);
        } catch (error) {
            assert(false);
        }
    });


    it('Проверяем state - должен быть CrowdSale...', async () => {
        const myState2 = await contract.methods.currentState().call({
            from: accounts[0],
            gas: "1000000"
        });
        assert(myState2 == 3);
    });

    //it('Проверка токенов на счетe 9 должно быть 5500 + 5000 = 10500...', async () => {
    //    let tokenBalance = await contract.methods.getBalanceTokens(accounts[9]).call();
    //    assert(tokenBalance == 10500 * (10**18));
    //    //console.log(tokenBalance / (10**18));
    //});

    it('increase time for 30 days - CrowdSale is closed...', async () => {
        const myVal = await new Promise((resolve, reject) =>
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [60 * 60 * 24 * 30],
            id: new Date().getTime()
        }, (error, result) => error ? reject(error) : resolve(result.result))
    );
    });

    it('Переводим 1 эфир на контракт от account[9] - должен отбить - пауза...', async () => {
        try {
            let funders = await contract.methods.AddBalanceContract().send({
                    from: accounts[9],
                    value: 1*10**18,
                    gas: '1000000'
                });
            assert(false);
        } catch (error) {
            assert(error);
        }
    });

    it('Проверяем state - должен быть все еще CrowdSale...', async () => {
        const myState2 = await contract.methods.currentState().call({
            from: accounts[0],
            gas: "1000000"
        });
        assert(myState2 == 3);
    });

    it('increase time for 31 days - Pause CrowdSale is passed...', async () => {
        const myVal = await new Promise((resolve, reject) =>
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [60 * 60 * 24 * 31],
            id: new Date().getTime()
        }, (error, result) => error ? reject(error) : resolve(result.result))
    );
    });

    it('Переводим 1 эфир на контракт от account[9] - должен принять, но при этом перейти в стадию Refunding (софт кап не достигнут)...', async () => {
        try {
            let funders = await contract.methods.AddBalanceContract().send({
                    from: accounts[9],
                    value: 1*10**18,
                    gas: '1000000'
                });
            assert(false);
        } catch (error) {
            assert(error);
        }
    });

    it('Проверяем state - должен быть Refunding...', async () => {
        const myState2 = await contract.methods.currentState().call({
            from: accounts[0],
            gas: "1000000"
        });
        assert(myState2 == 4);
        //console.log(myState2);
    });

    it('Проверка баланса на accounts[7] - 80 эфиров ...', async () => {
        accBalance = web3.utils.fromWei(await web3.eth.getBalance(accounts[7]), 'ether');
        assert(accBalance > 79);
        //console.log("Balance of accounts[7]: ", accBalance);
    });

    it('Возвращаем средства на account[7]...', async () => {
        try {
            await contract.methods.refund().send({
                from: accounts[7],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
        }
    });

    it('Проверка баланса на accounts[7] - 100 эфиров...', async () => {
        accBalance = web3.utils.fromWei(await web3.eth.getBalance(accounts[7]), 'ether');
        assert(accBalance > 99);
        //console.log("Balance of accounts[7]: ", accBalance);
    });

    it('Проверка токенов на счетe контракта...', async () => {
        let tokenBalance = await contract.methods.getBalanceTokens(contract.options.address).call();
        assert(tokenBalance > 10000000);
        console.log("Tokens on contract address:",tokenBalance);
    });

    it('Проверка токенов на счетe acounts[0]...', async () => {
        let tokenBalance = await contract.methods.getBalanceTokens(accounts[0]).call();
        assert(tokenBalance == 0);
        console.log("Tokens on accounts[0]:",tokenBalance);
    });

    it('Переводим все токены на accounts[0]...', async () => {
        try {
            await contract.methods.withdrawAllTokensFromBalance().send({
                from: accounts[0],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
        }
    });
    it('Проверка токенов на счетe контракта - должно быть ноль...', async () => {
        let tokenBalance = await contract.methods.getBalanceTokens(contract.options.address).call();
        assert(tokenBalance == 0);
        //console.log("Tokens on contract address:",tokenBalance);
    });

    it('Проверка токенов на счетe aсcounts[0]...', async () => {
        let tokenBalance = await contract.methods.getBalanceTokens(accounts[0]).call();
        assert(tokenBalance > 10000000);
        console.log("Tokens on accounts[0]:",tokenBalance);
    });
});
