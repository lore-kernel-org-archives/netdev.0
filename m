From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v11 0/5] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Mon, 14 Aug 2017 22:15:12 -0700 (PDT)
Message-ID: <20170814.221512.1430356980828045690.davem@davemloft.net>
References: <1502767407-6812-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, ashok.raj@intel.com, bhelgaas@google.com,
        helgaas@kernel.org, werner@chelsio.com, ganeshgr@chelsio.com,
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
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1502767407-6812-1-git-send-email-dingtianhong@huawei.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Tue, 15 Aug 2017 11:23:22 +0800

> Some devices have problems with Transaction Layer Packets with the Relaxed
> Ordering Attribute set.  This patch set adds a new PCIe Device Flag,
> PCI_DEV_FLAGS_NO_RELAXED_ORDERING, a set of PCI Quirks to catch some known
> devices with Relaxed Ordering issues, and a use of this new flag by the
> cxgb4 driver to avoid using Relaxed Ordering with problematic Root Complex
> Ports.
 ...

Series applied, thanks.
