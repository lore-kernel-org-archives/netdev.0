From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: ndisc: Neaten ND_PRINTx macros
Date: Thu, 17 May 2012 05:00:21 -0400 (EDT)
Message-ID: <20120517.050021.2267474481756476710.davem@davemloft.net>
References: <1337232518.17726.21.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337232518.17726.21.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 16 May 2012 22:28:38 -0700

> Why use several macros when one will do?
> 
> Convert the multiple ND_PRINTKx macros to a single
> ND_PRINTK macro.  Use the new net_<level>_ratelimited
> mechanism too.
> 
> Add pr_fmt with "ICMPv6: " as prefix.
> Remove embedded ICMPv6 prefixes from messages.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
