From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 09:30:10 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609163010.GA11509@netnation.com>
References: <20030608234926.GA9453@netnation.com> <001001c32e19$81bc7ea0$4a00000a@badass> <20030609064719.GA20613@netnation.com> <Pine.LNX.4.51.0306090918400.11389@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: ralph+d@istop.com
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.51.0306090918400.11389@ns.istop.com>
List-Id: netdev.vger.kernel.org

On Mon, Jun 09, 2003 at 09:28:59AM -0400, Ralph Doncaster wrote:

> The trick is finding the good IOS revs.  12.0(7)T and 12.2(11)T have been
> good ones for me.  Finding other ISPs running ciscos to exchange tips and
> ideas has been much easier than finding folks running linux.  A sure-fire
> way to get flamed is to post to NANOG asking what's the best Linux router
> setup!
> 
> For most ISPs it's better to spend $20K on a 7206VXR/NPE-G1 than to spend
> days trying to figure out what kernel + patch set, NIC, and motherboard
> combination will squeeze the best performance out of a PC router.  And
> once you've done that you still have zebra quirks to worry about...

I beg to differ.  We had much more pain trying to get those things to
work properly than putting together two boxes that have been up now for
almost a year without incident.  Running Zebra, keepalived, etc., without
any problems at all.  What Zebra quirks?  There has not yet been one
crash or failure, which is much better than we could say for the 7206s.

And I wouldn't exactly call it difficult to "squeeze" performance out of
a PC when the 7206 VXRs have a 200 MHz processor.

The main reason we switched is when we realized we could set up a
powerful Linux box full of gigabit NICs for less than the price of one
gigabit interface.  At the time we purchased the NICs (3C996B-T) for less
than $150 CDN each, and they're probably cheaper now.

Simon-
