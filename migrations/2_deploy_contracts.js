var Plans = artifacts.require("./Plans.sol");
var VolumeSubscription = artifacts.require("./VolumeSubscription.sol");
var TransferProxy = artifacts.require("./TransferProxy.sol");
var EightExToken = artifacts.require("./EightExToken.sol");
var Authorizable = artifacts.require("./Authorizable.sol");

module.exports = function(deployer) {

    deployer.deploy(EightExToken)
        .then(() => {
            return deployer.deploy(Authorizable); // TODO: Should not deploy to main net.
        }).then(() => {
            return deployer.deploy(TransferProxy);
        }).then(() => {
            return deployer.deploy(Plans);
        }).then(() => {
            return deployer.deploy(VolumeSubscription);
        })
};
