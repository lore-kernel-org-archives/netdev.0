From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 3/5] net: l2tp: netlink:
 l2tp_nl_tunnel_send: set UDP6 checksum flags
Date: Wed, 09 Nov 2016 18:56:37 -0500 (EST)
Message-ID: <20161109.185637.926914331516928518.davem@davemloft.net>
References: <20161107203928.30111-1-asbjorn@asbjorn.st>
        <20161107203928.30111-3-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: asbjorn@asbjorn.st
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161107203928.30111-3-asbjorn@asbjorn.st>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Date: Mon,  7 Nov 2016 20:39:26 +0000

> This patch causes the proper attribute flags to be set,
> in the case that IPv6 UDP checksums are disabled, so that
> userspace ie. `ip l2tp show tunnel` knows about it.
> 
> Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>

Applied.
