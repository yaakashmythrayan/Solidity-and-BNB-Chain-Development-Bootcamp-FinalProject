const fs = require("fs");
const FinalProject = artifacts.require("FinalProject");

module.exports = async function (deployer) {
await deployer.deploy(FinalProject);
const instance = await FinalProject.deployed();
let finalProjectAddress = await instance.address;
let config = "export const finalProjectAddress = " + finalProjectAddress;
console.log("finalProjectAddress = " + finalProjectAddress);
let data= JSON.stringify(config);
fs.writeFileSync("config.js", JSON.parse(data));
}
