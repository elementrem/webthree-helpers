web3.admin = {};
web3.admin.setSessionKey = function(s) { web3.admin.sessionKey = s; };

var getSessionKey = function () { return web3.admin.sessionKey; };

web3._extend({
    property: 'admin',
    methods: [new web3._extend.Method({
        name: 'setVerbosity',
        call: 'admin_setVerbosity',
        inputFormatter: [null, getSessionKey],
        params: 2
    }), new web3._extend.Method({
        name: 'net.start',
        call: 'admin_net_start',
        inputFormatter: [getSessionKey],
        params: 1
    }), new web3._extend.Method({
        name: 'net.stop',
        call: 'admin_net_stop',
        inputFormatter: [getSessionKey],
        params: 1
    }), new web3._extend.Method({
        name: 'net.connect',
        call: 'admin_net_connect',
        inputFormatter: [null, getSessionKey],
        params: 2
    }), new web3._extend.Method({
        name: 'net.peers',
        call: 'admin_net_peers',
        inputFormatter: [getSessionKey],
        params: 1
    }), new web3._extend.Method({
        name: 'ele.blockQueueStatus',
        call: 'admin_ele_blockQueueStatus',
        inputFormatter: [getSessionKey],
        params: 1
    }), new web3._extend.Method({
        name: 'exit',
        call: 'admin_exit',
        inputFormatter: [getSessionKey],
        params: 1
    }), new web3._extend.Method({
        name: 'net.nodeInfo',
        call: 'admin_net_nodeInfo',
        inputFormatter: [getSessionKey],
        params: 1
    }), new web3._extend.Method({
        name: 'ele.setAskPrice',
        call: 'admin_ele_setAskPrice',
        inputFormatter: [null, getSessionKey],
        params: 2
    }), new web3._extend.Method({
        name: 'ele.setBidPrice',
        call: 'admin_ele_setBidPrice',
        inputFormatter: [null, getSessionKey],
        params: 2
    }), new web3._extend.Method({
        name: 'ele.setReferencePrice',
        call: 'admin_ele_setReferencePrice',
        inputFormatter: [null, getSessionKey],
        params: 2
    }), new web3._extend.Method({
        name: 'ele.setPriority',
        call: 'admin_ele_setPriority',
        inputFormatter: [null, getSessionKey],
        params: 2
    }), new web3._extend.Method({
        name: 'ele.setMining',
        call: 'admin_ele_setMining',
        inputFormatter: [null, getSessionKey],
        params: 2
    }), new web3._extend.Method({
        name: 'ele.findBlock',
        call: 'admin_ele_findBlock',
        inputFormatter: [null, getSessionKey],
        params: 2
    }), new web3._extend.Method({
        name: 'ele.blockQueueFirstUnknown',
        call: 'admin_ele_blockQueueFirstUnknown',
        inputFormatter: [getSessionKey],
        params: 1
    }), new web3._extend.Method({
        name: 'ele.blockQueueRetryUnknown',
        call: 'admin_ele_blockQueueRetryUnknown',
        inputFormatter: [getSessionKey],
        params: 1
    }), new web3._extend.Method({
        name: 'ele.allAccounts',
        call: 'admin_ele_allAccounts',
        inputFormatter: [getSessionKey],
        params: 1
    }), new web3._extend.Method({
        name: 'ele.newAccount',
        call: 'admin_ele_newAccount',
        inputFormatter: [null, getSessionKey],
        params: 2
    }), new web3._extend.Method({
        name: 'ele.setSigningKey',
        call: 'admin_ele_setSigningKey',
        inputFormatter: [null, getSessionKey],
        params: 2
    }), new web3._extend.Method({
        name: 'ele.setMiningBenefactor',
        call: 'admin_ele_setMiningBenefactor',
        inputFormatter: [null, getSessionKey],
        params: 2
    }), new web3._extend.Method({
        name: 'ele.inspect',
        call: 'admin_ele_inspect',
        inputFormatter: [null, getSessionKey],
        params: 2
    }), new web3._extend.Method({
        name: 'ele.reprocess',
        call: 'admin_ele_reprocess',
        inputFormatter: [null, getSessionKey],
        params: 2
    }), new web3._extend.Method({
        name: 'ele.vmTrace',
        call: 'admin_ele_vmTrace',
        inputFormatter: [null, null, getSessionKey],
        params: 3
    }), new web3._extend.Method({
        name: 'ele.getReceiptByHashAndIndex',
        call: 'admin_ele_getReceiptByHashAndIndex',
        inputFormatter: [null, null, getSessionKey],
        params: 3
    })]
});

