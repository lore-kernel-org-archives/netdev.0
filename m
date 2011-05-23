From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for May 23 (infiniband + netlink)
Date: Mon, 23 May 2011 09:42:05 -0700
Message-ID: <20110523094205.4a5651d2.randy.dunlap@oracle.com>
References: <20110523154518.5e27cfb0.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-rdma@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110523154518.5e27cfb0.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 May 2011 15:45:18 +1000 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20110520:

when CONFIG_NET is not enabled:

ERROR: "skb_trim" [drivers/infiniband/core/ib_core.ko] undefined!
ERROR: "netlink_kernel_create" [drivers/infiniband/core/ib_core.ko] undefined!
ERROR: "netlink_kernel_release" [drivers/infiniband/core/ib_core.ko] undefined!
ERROR: "netlink_rcv_skb" [drivers/infiniband/core/ib_core.ko] undefined!
ERROR: "nla_put" [drivers/infiniband/core/ib_core.ko] undefined!
ERROR: "init_net" [drivers/infiniband/core/ib_core.ko] undefined!
ERROR: "netlink_dump_start" [drivers/infiniband/core/ib_core.ko] undefined!
ERROR: "skb_put" [drivers/infiniband/core/ib_core.ko] undefined!

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
