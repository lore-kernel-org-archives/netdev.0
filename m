From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netem update for 2.4
Date: Wed, 25 May 2005 23:15:58 -0700 (PDT)
Message-ID: <20050525.231558.104645147.davem@davemloft.net>
References: <20050525135920.659f3a00@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netem@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20050525135920.659f3a00@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 25 May 2005 13:59:20 -0700

> This includes the netem changes for 2.6 retargeted for 2.4
> It covers:
> 	* make duplication reinsert from root to fix qlen issues
> 	* just use embedded qdisc for queueing to avoid qlen issues
> 	* probabilistic reordering support

Let's keep 2.4.x to pure bug fixes, so the new reordering
support should be omitted.  Thanks.
