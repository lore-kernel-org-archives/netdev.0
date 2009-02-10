From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Remaining bits for basic support of LDP
Date: Tue, 10 Feb 2009 21:37:12 +0000
Message-ID: <20090210213712.GB19041@n2100.arm.linux.org.uk>
References: <20090202213953.GB16069@n2100.arm.linux.org.uk> <20090202.134530.63616213.davem@davemloft.net> <20090202222909.GC16069@n2100.arm.linux.org.uk> <20090210114855.GA9746@n2100.arm.linux.org.uk> <20090210115615.GA9869@n2100.arm.linux.org.uk> <20090210210159.GK14200@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090210210159.GK14200@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2009 at 01:02:02PM -0800, Tony Lindgren wrote:
> Yeah, the smsc updates for omap might take a while longer to get going.
> So here's my ack for this smc911x patch:
> 
> Acked-by: Tony Lindgren <tony@atomide.com>

Thanks.

> For the smsc changes, I don't have an LDP to test with. But I'll try
> to get another board to work with smsc now that I have some MMC voltage
> weirdness out of the way and have a proper root on MMC :) That is after
> I have musb working on it so I can scp the module over g_ether..

I've tested them both on the LDP, both work fine.

That talk of MMC voltage weirdness sounds like bug fixes - do they
need to get into mainline?
