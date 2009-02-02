From: Tony Lindgren <tony@atomide.com>
Subject: Re: Remaining bits for basic support of LDP
Date: Mon, 2 Feb 2009 15:57:45 -0800
Message-ID: <20090202235741.GX7215@atomide.com>
References: <20090202213953.GB16069@n2100.arm.linux.org.uk> <20090202.134530.63616213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux@arm.linux.org.uk, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090202.134530.63616213.davem@davemloft.net>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> [090202 13:45]:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Mon, 2 Feb 2009 21:39:53 +0000
> 
> > The patch to fix these issues would seem to be relatively small (12
> > lines in the smc911x and one line change in board-ldp.c) - is it
> > something we want done for -rc4 or do we scrap the ethernet support 
> > on the LDP until the SMSC driver has been merged ?

Would be nice to have it of course!

> > Obviously, having working ethernet would be helpful, and since it was
> > half heartedly merged when the initial OMAP3 stuff went upstream we
> > should do something with it one way or another.
> 
> Well, the SMSC driver is there already in the tree.
> 
> The only thing not currently being scheduled to hit
> 2.6.29-rcX are the recent changes to support platform
> specified interrupt flags and all of that stuff.
> 
> If you want, we can look into pushing that work into
> 2.6.29-rcX

That would be great, more platforms to test it on.

Tony
