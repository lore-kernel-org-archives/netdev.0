From: David Miller <davem@davemloft.net>
Subject: Re: [v3 PATCH 1/2] netprio_cgroup: Remove update_netdev_tables()
 since it is unnecessary
Date: Thu, 13 Sep 2012 16:19:06 -0400 (EDT)
Message-ID: <20120913.161906.1620891081013420444.davem@davemloft.net>
References: <20120913063225.6278.87780.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, David.Laight@aculab.com,
	john.r.fastabend@intel.com, gaofeng@cn.fujitsu.com,
	eric.dumazet@gmail.com, mark.d.rustad@intel.com,
	lizefan@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: srivatsa.bhat@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120913063225.6278.87780.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Date: Thu, 13 Sep 2012 12:02:25 +0530

> The update_netdev_tables() function appears to be unnecessary, since the
> write_update_netdev_table() function will adjust the priomaps as and when
> required anyway. So drop the usage of update_netdev_tables() entirely.
> 
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>

Applied to net-next
