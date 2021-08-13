App = {
    web3Provider: null,
    contracts: {},
    //emptyAddress: "0x0000000000000000000000000000000000000000",
    //sku: 0,
    upc: 0,
    metamaskAccountID: "0x0000000000000000000000000000000000000000",
    ownerID: "0x0000000000000000000000000000000000000000",

    producerID: "0x0000000000000000000000000000000000000000",
    producerName: null,
    producerInformation: null,
    articleID: null,
    articleNotes: null,
    articleState: null,
    distributorID: "0x0000000000000000000000000000000000000000",
    distributorName: "0x0000000000000000000000000000000000000000",
    clientID: "0x0000000000000000000000000000000000000000",

    init: async function () {
        
        /// Setup access to blockchain
        return await App.initWeb3();
    },

    initWeb3: async function () {
        /// Find or Inject Web3 Provider
        /// Modern dapp browsers...
        if (window.ethereum) {
            App.web3Provider = window.ethereum;
            try {
                // Request account access
                await window.ethereum.enable();
            } catch (error) {
                // User denied account access...
                console.error("User denied account access")
            }
        }
        // Legacy dapp browsers...
        else if (window.web3) {
            App.web3Provider = window.web3.currentProvider;
        }
        // If no injected web3 instance is detected, fall back to Ganache
        else {
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
        }

        App.getMetaskAccountID();

        return App.initSupplyChain();
    },

    getMetaskAccountID: function () {
        web3 = new Web3(App.web3Provider);

        // Retrieving accounts
        web3.eth.getAccounts(function(err, res) {
            if (err) {
                console.log('Error:',err);
                return;
            }
            console.log('getMetaskID:',res);
            App.metamaskAccountID = res[0];

        })
    },

    initSupplyChain: function () {
        /// Source the truffle compiled smart contracts
        var jsonSupplyChain='./build/contracts/PharmaSupplyChain.json';
        
        /// JSONfy the smart contracts
        $.getJSON(jsonSupplyChain, function(data) {
            console.log('data',data);
            var SupplyChainArtifact = data;
            App.contracts.SupplyChain = TruffleContract(SupplyChainArtifact);
            App.contracts.SupplyChain.setProvider(App.web3Provider);
            
           // App.articleTraceProducer();
            //fetchMedicineBufferOne
           // App.fetchMedicineBufferTwo();
            App.fetchEvents();

        });

        return App.bindEvents();
    },

    bindEvents: function() {
        $('.databtn').on('click', App.handleButtonClick);
    },

    handleButtonClick: async function(event) {
        event.preventDefault();

        await App.getMetaskAccountID();
        
        let processId =  event.target && $(event.target).data('id') &&  +($(event.target).data('id'));
       if(processId) {
        switch(processId) {
            case 1:
                return await App.produceArticleByProducer(event);
                break;
            case 2:
                return await App.articleTraceProducer(event);
                break;
            case 3:
                return await App.orderArticleByDistributor(event);
                break;
            case 4:
                return await App.sendArticleToDistributor(event);
                break;
            case 5:
                return await App.sellArticleByDistributor(event);
                break;
            case 6:
                return await App.orderArticleByClient(event);
                break;
            case 7:
                return await App.sendArticleToClient(event);
                break;
            case 8:
                return await App.articleTraceProducer(event);
                break;
            case 9:
                return await App.articleTraceDistributor(event);
                break;
            }
       }

   
    },

    produceArticleByProducer: function(event) {
        event.preventDefault();
        App.upc = $("#upc").val();
        App.producerName = $("#producerName").val();
        App.producerInformation = $("#producerInformation").val();
        App.articleNotes = $("#articleNotes").val();
        App.contracts.SupplyChain.deployed().then(function(instance) {
            
            return instance.produceArticleByProducer(
                App.upc, 
                App.metamaskAccountID, 
                App.producerName, 
                App.producerInformation,
                App.articleNotes,
                {from: App.metamaskAccountID, gas:3000000}                   
            );
        }).then(function(result) {
            console.log('makeMedicine',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    articleTraceProducer: function () {

            App.upc = $('#upc').val();    
            var displayTo = document.getElementById("ftc-medicine");
            App.contracts.SupplyChain.deployed().then(function(instance) {
              return instance.articleTraceProducer(App.upc);
            }).then(function(result) {
              
                while (displayTo.firstChild) {
                    displayTo.removeChild(displayTo.firstChild);
                }
                displayTo.innerHTML = (
                   
                "UPC: "+result[1]+"<br>"+
                "Nom du fabricant: "+result[4]+"<br>"+
                "Status: 0 <br>"+
                "Information sur le fabricant: "+result[5]+"<br>");
                

            }).catch(function(err) {
              console.log(err.message);
            });
        },

   /* processMedicine: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.processMedicine(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-medicine").text(result);
            console.log('processMedicine',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },
    
    packMedicine: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.packMedicine(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-medicine").text(result);
            console.log('packMedicine',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    sellMedicine: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            const medicinePrice = web3.toWei(1, "ether");
            console.log('medicinePrice',medicinePrice);
            return instance.sellMedicine(App.upc, App.medicinePrice, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-medicine").text(result);
            console.log('sellMedicine',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    buyMedicine: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            const walletValue = web3.toWei(3, "ether");
            return instance.buyMedicine(App.upc, {from: App.metamaskAccountID, value: walletValue});
        }).then(function(result) {
            $("#ftc-medicine").text(result);
            console.log('buyMedicine',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    shipMedicine: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.shipMedicine(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-medicine").text(result);
            console.log('shipMedicine',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    receiveMedicine: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.receiveMedicine(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-medicine").text(result);
            console.log('receiveMedicine',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    purchaseMedicine: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.purchaseMedicine(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-medicine").text(result);
            console.log('purchaseMedicine',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    fetchMedicineBufferTwo: function () {
    ///    event.preventDefault();
    ///    var processId = parseInt($(event.target).data('id'));
                        
        App.contracts.SupplyChain.deployed().then(function(instance) {
          return instance.fetchMedicineBufferTwo.call(App.upc);
        }).then(function(result) {
          $("#ftc-medicine").text(result);
          console.log('fetchMedicineBufferTwo', result);
        }).catch(function(err) {
          console.log(err.message);
        });
    }, */

    fetchEvents: function () {
        if (typeof App.contracts.SupplyChain.currentProvider.sendAsync !== "function") {
            App.contracts.SupplyChain.currentProvider.sendAsync = function () {
                return App.contracts.SupplyChain.currentProvider.send.apply(
                App.contracts.SupplyChain.currentProvider,
                    arguments
              );
            };
        }

        App.contracts.SupplyChain.deployed().then(function(instance) {
        var events = instance.allEvents(function(err, log){
          if (!err)
            $("#ftc-events").append('<li>' + log.event + ' - ' + log.transactionHash + '</li>');
        });
        }).catch(function(err) {
          console.log(err.message);
        });
        
    }
};

$(function () {
    $(window).load(function () {
        App.init();
    });
});