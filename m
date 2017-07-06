From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH v6 0/3] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Thu, 6 Jul 2017 12:17:30 -0500
Message-ID: <20170706171729.GP13824@bhelgaas-glaptop.roam.corp.google.com>
References: <1498133721-21152-1-git-send-email-dingtianhong@huawei.com>
 <43e01fca-a746-90d2-fdfa-c63f1d56ef5f@huawei.com>
 <065edbdb-3a7f-2608-3cc0-3876f55d414b@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: leedom@chelsio.com, ashok.raj@intel.com, werner@chelsio.com,
        ganeshgr@chelsio.com, asit.k.mallick@intel.com,
        patrick.j.cramer@intel.com, Suravee.Suthikulpanit@amd.com,
        Bob.Shaw@amd.com, l.stach@pengutronix.de, amira@mellanox.com,
        gabriele.paoloni@huawei.com, David.Laight@aculab.com,
        jeffrey.t.kirsher@intel.com, catalin.marinas@arm.com,
        will.deacon@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
        davem@davemloft.net, alexander.duyck@gmail.com,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <065edbdb-3a7f-2608-3cc0-3876f55d414b@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 06, 2017 at 08:58:51PM +0800, Ding Tianhong wrote:
> Hi Bjorn:
> 
> Could you please give some feedback about this patchset, it looks like no more comments for more than a week,
> thanks. :)

I was on vacation when you posted it, but don't worry, it's still in
the queue:

  https://patchwork.ozlabs.org/project/linux-pci/list

v4.12 was just released, so it's obviously too late for that.  The
v4.13 merge window is open, so it's too late for v4.13 as well (we
need stuff in -next before the merge window).

There's still plenty of time to work on this for v4.14.

Bjorn
