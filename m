From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [RFC PATCHv2 0/4] Add DT support for fixed PHYs
Date: Mon, 10 Feb 2014 13:09:46 +0100
Message-ID: <20140210130946.6a554659@skate>
References: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<20130911064248.GI30088@pengutronix.de>
	<CAH9NwWfBGHmZ+HfUndeh18NW+HyZ=c82W=O_4hJSOH-oZuM9jA@mail.gmail.com>
	<CAH9NwWfutp6MitSuG-LNH=0Y0ffewuSawLXJOe2JUL7=tz7BWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	devicetree@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Mark Rutland <mark.rutland@arm.com>
To: Christian Gmeiner <christian.gmeiner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:57449 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752214AbaBJMJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 07:09:49 -0500
In-Reply-To: <CAH9NwWfutp6MitSuG-LNH=0Y0ffewuSawLXJOe2JUL7=tz7BWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Christian Gmeiner,

On Mon, 10 Feb 2014 11:30:30 +0100, Christian Gmeiner wrote:

> >> +1 for the general idea. This really looks good now. I've not much more
> >> to say. Maybe someone from the devicetree corner has a few words for the
> >> binding?
> >>
> >
> > I tested the whole series with an I.MX6D board with the FEC driver:
> > fec 2188000.ethernet eth0: Freescale FEC PHY driver [Generic PHY]
> > (mii_bus:phy_addr=fixed-0:00, irq=-1)
> >
> > For me binding looks nice and I hope to see this patch series in 3.13.
> >
> > Tested-by: Christian Gmeiner <christian.gmeiner@gmail.com>
> 
> Is there any update on this patch series?

I'll try to send a new version in the next few days. It's still part of
my TODO list.

Thanks!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
