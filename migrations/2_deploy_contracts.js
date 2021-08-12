// migrating the appropriate contracts
var DistributorRole = artifacts.require("./RoleDistributor.sol");
var ProducerRole = artifacts.require("./RoleProducer.sol");
var ClientRole = artifacts.require("./RoleClient.sol");
var PharmaSupplyChain = artifacts.require("./PharmaSupplyChain.sol");

module.exports = function(deployer) {
  deployer.deploy(DistributorRole);
  deployer.deploy(ProducerRole);
  deployer.deploy(ClientRole);
  deployer.deploy(PharmaSupplyChain);
};