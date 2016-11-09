From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/5] net: l2tp: change
 L2TP_ATTR_UDP_ZERO_CSUM6_{RX,TX} attribute types
Date: Wed, 09 Nov 2016 18:56:23 -0500 (EST)
Message-ID: <20161109.185623.417195295208488150.davem@davemloft.net>
References: <20161107203928.30111-1-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, therbert@google.com
To: asbjorn@asbjorn.st
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161107203928.30111-1-asbjorn@asbjorn.st>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Date: Mon,  7 Nov 2016 20:39:24 +0000

> The attributes L2TP_ATTR_UDP_ZERO_CSUM6_RX and
> L2TP_ATTR_UDP_ZERO_CSUM6_TX are used as flags,
> but is defined as a u8 in a comment.
> 
> This patch redocuments them as flags.
> 
> Adding nla_policy entries would break API, so not doing that.
> 
> CC: Tom Herbert <therbert@google.com>
> Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>

Applied.
