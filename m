From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] remove superfluous diverter printk'ing
Date: Sat, 15 Jan 2005 11:47:50 +0100
Message-ID: <20050115104750.GB14991@xi.wantstofly.org>
References: <20050114124700.GA4079@xi.wantstofly.org> <20050114134642.4be4e2fc.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050114134642.4be4e2fc.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jan 14, 2005 at 01:46:42PM -0800, David S. Miller wrote:

> > You're not listed as diverter maintainer but I'm sending this via
> > you anyway.  This patch removes some printk'ing from the diverter
> > driver (and cleans up the code a bit), because after a while it gets
> > really annoying to have log messages like this one for every single
> > tunnel you create or tear down.
> > 
> > 	divert: not allocating divert_blk for non-ethernet device tunl0
> > 
> > Please consider sending upstream.
> 
> Those diverter messages drive me crazy too, I think I'll
> add your patch Lennert.

Benoit's email address bounces, and it's the latest address of his I
could find, so if he doesn't read this list you might as well go ahead.


cheers,
Lennert
