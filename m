From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-next 0/7] bonding: slight optimization for
 bonding
Date: Wed, 01 Jan 2014 22:59:29 -0500 (EST)
Message-ID: <20140101.225929.656895130870992841.davem@davemloft.net>
References: <52C4BD12.8000502@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, joe@perches.com,
	julia.lawall@lip6.fr, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52C4BD12.8000502@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Thu, 2 Jan 2014 09:12:50 +0800

> This serious of patches will slight optimize the mac address compare
> and xmit path for bonding, also make some cleanups.
> 
> Julia was using ether_addr_equal_64bits to instead of ether_addr_equal,
> it is really a hard work and she may did not make patch for bonding yet,
> so I have do it in this patchset and that she could miss the bonding drivers.
> 
> resend and add cc for Julia.

Series applied, thank you.
