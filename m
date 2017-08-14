From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v10 0/5] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Mon, 14 Aug 2017 11:15:31 -0700 (PDT)
Message-ID: <20170814.111531.1800078635180250504.davem@davemloft.net>
References: <1502725499-11276-1-git-send-email-dingtianhong@huawei.com>
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
In-Reply-To: <1502725499-11276-1-git-send-email-dingtianhong@huawei.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It looks like we are really close on this.

Please just remove the Intel signoff from the AMD patch, and I don't
think it's wise to wait for an AMD person to signoff on it given
the state of affairs for that chipset.

Thanks.
