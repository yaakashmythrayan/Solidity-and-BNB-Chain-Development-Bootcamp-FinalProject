const FinalProject=artifacts.require("FinalProject");

contract("FinalProject", accounts=>{
    let finalproject;
    const owner=accounts[0];
    const user1 = accounts[1];
    const count=accounts.length;

    beforeEach(async () => {
        finalproject = await FinalProject.new();
    });

    describe ("Add user", ()=> {
        it("adds a new user", async ()=>{
            await finalproject.addUser("Aakash",{from:user1});
            const user = await finalproject.getUser(user1);
            assert.equal(user.name,"Aakash","Problem with user name");
        });
    }); 

    describe("Deposit token", () => {
        it("deposits token", async () => {
        await finalproject.addUser("Aakash", { from: user1 }); 
        await finalproject.deposit({ from: user1, value: 100 }); 
        const user = await finalproject.getUser(user1); 
        assert.equal(user.balance, 100, "User could not deposit tokens");
        });
    });

    describe("Lock Tokens", () => {
        it("user locks tokens", async () => { 
            await finalproject.addUser("Aakash",{ from: user1 }); 
            await finalproject.deposit({ from: user1, value: 100 }); 
            await finalproject.lock(50,2,{from: user1});
            const newStatus = 1;
            const user = await finalproject.getUser(user1);
            assert.equal(user.balance,50,"Problem With Balance");
            assert.equal(user.status,newStatus,"Problem With Status");
        });
    });

    describe("Unlock Tokens", () => {
        it("user unlocks tokens", async () => { 
            await finalproject.addUser("Aakash",{ from: user1 }); 
            await finalproject.deposit({ from: user1, value: 100 }); 
            await finalproject.lock(50,2,{from:user1});
            await finalproject.unlock({from:user1});
            const user = await finalproject.getUser(user1);
            const newStatus=0;
            assert.equal(user.balance,100,"Problem With Balance");
            assert.equal(user.status,newStatus,"Problem With Status");
        });
    }); 
});
