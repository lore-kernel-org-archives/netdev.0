From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9 0/4] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Mon, 07 Aug 2017 14:14:48 -0700 (PDT)
Message-ID: <20170807.141448.1388035794329323595.davem@davemloft.net>
References: <1501917313-9812-1-git-send-email-dingtianhong@huawei.com>
        <20170806.204744.1934067595236180060.davem@davemloft.net>
        <588b378c-249a-36b0-8890-769258fbb708@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: bhelgaas@google.com, helgaas@kernel.org, leedom@chelsio.com,
        ashok.raj@intel.com, werner@chelsio.com, ganeshgr@chelsio.com,
        asit.k.mallick@intel.com, patrick.j.cramer@intel.com,
        Suravee.Suthikulpanit@amd.com, Bob.Shaw@amd.com,
        l.stach@pengutronix.de, amira@mellanox.com,
        gabriele.paoloni@huawei.com, David.Laight@aculab.com,
        jeffrey.t.kirsher@intel.com, catalin.marinas@arm.com,
        will.deacon@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
        alexander.duyck@gmail.com, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, linux-pci@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: dingtianhong@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <588b378c-249a-36b0-8890-769258fbb708@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Mon, 7 Aug 2017 12:13:17 +0800

> Hi David：
> 
> I think networking tree merge it is a better choice, as it mainly used to tell the NIC
> drivers how to use the Relaxed Ordering Attribute, and later we need send patch to enable
> RO for ixgbe driver base on this patch. But I am not sure whether Bjorn has some of his own
> view. :)
> 
> Hi Bjorn:
> 
> Could you help review this patch or give some feedback ?

I'm still waiting on this...

Bjorn?
