// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
contract BurnToken is ERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    uint8 private constant _decimals = 9;
    address public constant deadAddress = address(0xdead);
    address private utility1Address;
    address private utility2Address;
    address private utility3Address;
    address private utility4Address;
    bool private swapping;
    uint256 public maxTransactionAmount;
    uint256 public swapTokensAtAmount;
    uint256 public maxWallet;
    uint256 public supply;
    address public staking;
    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = true;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = true;
    uint256 public buyBurnFee;
    uint256 public buyVaultFee;
    uint256 public buyTotalFees;
    uint256 public sellBurnFee;
    uint256 public sellVaultFee;
    uint256 public sellTotalFees;   
    uint256 public tokensForBurn;
    uint256 public tokensForVault;
    uint256 public walletDigit;
    uint256 public transDigit;
    uint256 public delayDigit;
    mapping (address => bool) public _isExcludedFromFees;
    mapping (address => bool) public _isExcludedMaxTransactionAmount;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => bool) public bots;
    mapping (address => bool) public floorControl;
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    struct Distribution {
        uint256 utility1;
        uint256 utility2;
        uint256 utility3;
        uint256 utility4;
    }

    Distribution public distribution;

    constructor(address utility1Addr, address utility2Addr, address utility3Addr, address utility4Addr) ERC20("Burn Token", "BURN2") {
        utility1Address = utility1Addr;
        utility2Address = utility2Addr;
        utility3Address = utility3Addr;
        utility4Address = utility4Addr;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        uint256 totalSupply = 200_000_000 * 10**_decimals;
        supply += totalSupply;
        walletDigit = 1;
        transDigit = 1;
        delayDigit = 0;
        maxTransactionAmount = supply * transDigit / 100;
        swapTokensAtAmount = supply * 5 / 10000; 
        maxWallet = supply * walletDigit / 100;

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);
        excludeFromFees(address(utility1Address), true);
        excludeFromFees(address(utility2Address), true);
        excludeFromFees(address(utility3Address), true);
        excludeFromFees(address(utility4Address), true);

        excludeFromMaxTransaction(owner(), true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(0xdead), true);
        excludeFromMaxTransaction(address(utility1Address), true);
        excludeFromMaxTransaction(address(utility2Address), true);
        excludeFromMaxTransaction(address(utility3Address), true);
        excludeFromMaxTransaction(address(utility4Address), true);
        excludeFromMaxTransaction(address(uniswapV2Router), true);
        excludeFromMaxTransaction(address(uniswapV2Pair), true);

        distribution = Distribution(25, 25, 25, 25);
        _approve(owner(), address(uniswapV2Router), totalSupply);
        _mint(msg.sender, totalSupply);
    }
    receive() external payable {
  	}
    function enableTrading() external onlyOwner {
        buyBurnFee = 1;
        buyVaultFee = 9;
        buyTotalFees = buyBurnFee + buyVaultFee;
        sellBurnFee = 1;
        sellVaultFee = 9;
        sellTotalFees = sellBurnFee + sellVaultFee;
        delayDigit = 5;
        tradingActive = true;
    }

    function blockBots(address[] memory bots_) public onlyOwner {
        for (uint256 i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function unblockBot(address[] calldata accounts) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            delete bots[accounts[i]];
        }
    }

    function updateTransDigit(uint256 newNum) external onlyOwner {
        require(newNum >= 1);
        transDigit = newNum;
        updateLimits();
    }
    function updateWalletDigit(uint256 newNum) external onlyOwner {
        require(newNum >= 1);
        walletDigit = newNum;
        updateLimits();
    }
    function updateDelayDigit(uint256 newNum) external onlyOwner{
        delayDigit = newNum;
    }

    // disable Transfer delay - cannot be reenabled
    function disableTransferDelay() external onlyOwner returns (bool){
        transferDelayEnabled = false;
        return true;
    }

    // remove limits after token is stable
    function removeLimits() external onlyOwner returns (bool){
        limitsInEffect = false;
        return true;
    }

    function excludeFromMaxTransactionAdd(address[] memory accounts) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
           _isExcludedMaxTransactionAmount[accounts[i]] = true;
        }
    }

    function excludeFromMaxTransactionRemove(address[] calldata accounts) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            delete _isExcludedMaxTransactionAmount[accounts[i]];
        }
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    function updateBuyFees(uint256 _burnFee, uint256 _vaultFee) external onlyOwner {
        buyBurnFee = _burnFee;
        buyVaultFee = _vaultFee;
        buyTotalFees = buyBurnFee + buyVaultFee;
        require(buyTotalFees <= 25, "Must keep fees at 25% or less");
    }

    function updateSellFees(uint256 _burnFee, uint256 _vaultFee) external onlyOwner {
        sellBurnFee = _burnFee;
        sellVaultFee = _vaultFee;
        sellTotalFees = sellBurnFee + sellVaultFee;
        require(sellTotalFees <= 25, "Must keep fees at 25% or less");
    }
    
    function updateUtility1(address utilityAddress) external onlyOwner {
        utility1Address = utilityAddress;
    }

     function updateUtility2(address utilityAddress) external onlyOwner {
        utility2Address = utilityAddress;
    }

     function updateUtility3(address utilityAddress) external onlyOwner {
        utility3Address = utilityAddress;
    }

     function updateUtility4(address utilityAddress) external onlyOwner {
        utility4Address = utilityAddress;
    }

    function excludeFromFeesAdd(address[] memory accounts) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = true;
            emit ExcludeFromFees(accounts[i], true);
        }
    }

    function excludeFromFeesRemove(address[] calldata accounts) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
                  delete _isExcludedFromFees[accounts[i]];
        }
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function updateLimits() private {
        maxTransactionAmount = supply * transDigit / 100;
        swapTokensAtAmount = supply * 5 / 10000; 
        maxWallet = supply * walletDigit / 100;
    }
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }
    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

     function setDistribution(uint256 utility1, uint256 utility2, uint256 utility3, uint256 utility4) external onlyOwner {      
        require(utility1 + utility2 + utility3 + utility4 == 100, "Sum must equal 100");
        distribution.utility1 = utility1;
        distribution.utility2 = utility2;
        distribution.utility3 = utility3;
        distribution.utility4 = utility4;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
         if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        if(limitsInEffect){
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !swapping
            ){
                if(!tradingActive){
                    require(_isExcludedFromFees[from] || _isExcludedFromFees[to] || floorControl[from] || floorControl[to], "Trading is not active.");
                }                
                require(!bots[from] && !bots[to], "TOKEN: Your account is blacklisted!");
                if (transferDelayEnabled){
                    if (to != owner() && to != address(uniswapV2Router) && to != address(uniswapV2Pair) && to != address(utility1Address) && from != address(utility1Address) && to != address(utility2Address) && from != address(utility2Address)){
                        require(_holderLastTransferTimestamp[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed.");
                        _holderLastTransferTimestamp[tx.origin] = block.number + delayDigit;
                    }
                }
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                        require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTransactionAmount.");
                        require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                }
                else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                        require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxTransactionAmount.");
                }
                else if(!_isExcludedMaxTransactionAmount[to]){
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded");
                }
            }
        }
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        if( 
            canSwap &&
            !swapping &&
            swapEnabled &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;
            swapBack();
            swapping = false;
        }
        bool takeFee = !swapping;
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        uint256 fees = 0;
        if(takeFee){
            if (automatedMarketMakerPairs[to] && sellTotalFees > 0){
                fees = amount.mul(sellTotalFees).div(100);
                tokensForVault += fees * sellVaultFee / sellTotalFees;
                tokensForBurn += fees - tokensForVault;
            }
            else if(automatedMarketMakerPairs[from] && buyTotalFees > 0) {
        	    fees = amount.mul(buyTotalFees).div(100);
                tokensForVault += fees * buyVaultFee / buyTotalFees;
        	    tokensForBurn += fees - tokensForVault;
            }
            if(fees > 0){    
                super._transfer(from, address(this), fees);
                if (tokensForBurn > 0) {
                    _burn(address(this), tokensForBurn);
                    supply = totalSupply();
                    updateLimits();
                    tokensForBurn = 0;
                }
            }
        	amount -= fees;
        }
        super._transfer(from, to, amount);
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }
    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        bool success;
        if(contractBalance == 0) {return;}
        if(contractBalance > swapTokensAtAmount * 20){
          contractBalance = swapTokensAtAmount * 20;
        }
        swapTokensForEth(contractBalance);
        uint256 distributionEth = address(this).balance; 
        tokensForVault = 0;
        (success,) = address(utility1Address).call{value: distributionEth.mul(distribution.utility1).div(100)}("");
        (success,) = address(utility2Address).call{value: distributionEth.mul(distribution.utility2).div(100)}("");
        (success,) = address(utility3Address).call{value: distributionEth.mul(distribution.utility3).div(100)}("");
        (success,) = address(utility4Address).call{value: distributionEth.mul(distribution.utility4).div(100)}("");
    }

    // Withdraw an ERC20 Token from contract
    function withdrawToken(address _tokenContract, uint256 _amount) public onlyOwner  {
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(msg.sender, _amount);
    }
    
    function allowFloorControl(address[] calldata accounts) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            floorControl[accounts[i]] = true;
        }
    }

    function removeFloorControl(address[] calldata accounts) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            delete floorControl[accounts[i]];
        }
    }
}
