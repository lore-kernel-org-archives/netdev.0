From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] remove superfluous diverter printk'ing
Date: Fri, 14 Jan 2005 13:46:42 -0800
Message-ID: <20050114134642.4be4e2fc.davem@davemloft.net>
References: <20050114124700.GA4079@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: benwa@club-internet.fr, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050114124700.GA4079@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 14 Jan 2005 13:47:00 +0100
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> You're not listed as diverter maintainer but I'm sending this via
> you anyway.  This patch removes some printk'ing from the diverter
> driver (and cleans up the code a bit), because after a while it gets
> really annoying to have log messages like this one for every single
> tunnel you create or tear down.
> 
> 	divert: not allocating divert_blk for non-ethernet device tunl0
> 
> Please consider sending upstream.

Those diverter messages drive me crazy too, I think I'll
add your patch Lennert.
