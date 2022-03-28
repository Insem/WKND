const Web3 = require('web3');
const solc = require('solc');
const fs =  require('fs');
const Contract = require('web3-eth-contract');
//const web3_socket = new Web3.providers.WebsocketProvider('ws://localhost:8546');
const web3_http = new Web3.providers.HttpProvider('http://localhost:8545');

const CONTRACT_ADDR = "477d598c3e43bbfaabbcfe8a8d97407d8ff2fd20";
const CONTRACT_PATH = "./sol/wakanda.sol";
const CONTRACT_NAME = "ERC20WKND";

const web3 = new Web3(new Web3(Web3.givenProvider ||  web3_http));
async function intit() {
const input = {
  language: 'Solidity',
  sources: {
    'wakanda': {
      content: fs.readFileSync(CONTRACT_PATH, 'utf-8')
    }
  },
  settings: {
    outputSelection: {
      '*': {
        '*': ['*']
      }
    }
  }
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));
const raw_contract = output.contracts.wakanda[CONTRACT_NAME].abi;
const id = await web3.eth.net.getId();
const contract = new web3.eth.Contract(raw_contract, CONTRACT_ADDR);
const total = await contract.methods.getSender().call( {from:"0x022d71a77b76b77e6e0f08a0771fdade369fc338"},async (err, res)=>{
});
}
intit();