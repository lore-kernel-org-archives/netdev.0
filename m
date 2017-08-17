From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net RESEND] PCI: fix oops when try to find Root Port for a
 PCI device
Date: Thu, 17 Aug 2017 09:14:06 +0800
Message-ID: <fe758f12-9f9c-3878-ccb8-ebf232098888@huawei.com>
References: <20170815170331.GA4099@bhelgaas-glaptop.roam.corp.google.com>
 <20170816193303.GA14147@ulmo>
 <20170816200237.GE28977@bhelgaas-glaptop.roam.corp.google.com>
 <20170816.135952.1915098012719012810.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <thierry.reding@gmail.com>, <mark.rutland@arm.com>,
        <gabriele.paoloni@huawei.com>, <asit.k.mallick@intel.com>,
        <catalin.marinas@arm.com>, <will.deacon@arm.com>,
        <linuxarm@huawei.com>, <alexander.duyck@gmail.com>,
        <ashok.raj@intel.com>, <eric.dumazet@gmail.com>,
        <jeffrey.t.kirsher@intel.com>, <linux-pci@vger.kernel.org>,
        <ganeshgr@chelsio.com>, <Bob.Shaw@amd.com>, <leedom@chelsio.com>,
        <patrick.j.cramer@intel.com>, <bhelgaas@google.com>,
        <werner@chelsio.com>, <linux-arm-kernel@lists.infradead.org>,
        <amira@mellanox.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <David.Laight@aculab.com>,
        <Suravee.Suthikulpanit@amd.com>, <robin.murphy@arm.com>,
        <l.stach@pengutronix.de>
To: David Miller <davem@davemloft.net>, <helgaas@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170816.135952.1915098012719012810.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/8/17 4:59, David Miller wrote:
> From: Bjorn Helgaas <helgaas@kernel.org>
> Date: Wed, 16 Aug 2017 15:02:37 -0500
> 
>> Your fix looks right to me.
> 
> Someone please submit this fix formally because this change is now in
> Linus's tree.
> 

I will send it.

> Thank you.
> 
> .
> 
