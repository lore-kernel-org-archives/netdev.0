From: David Miller <davem@davemloft.net>
Subject: Re: FEC Patches
Date: Wed, 28 Jan 2009 12:31:10 -0800 (PST)
Message-ID: <20090128.123110.120011613.davem@davemloft.net>
References: <1233052804-31228-1-git-send-email-s.hauer@pengutronix.de>
	<49800B31.9020608@snapgear.com>
	<20090128185339.GD8446@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerg@snapgear.com, netdev@vger.kernel.org, fred.rodo@gmail.com
To: s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39420
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754787AbZA1UbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 15:31:12 -0500
In-Reply-To: <20090128185339.GD8446@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer <s.hauer@pengutronix.de>
Date: Wed, 28 Jan 2009 19:53:39 +0100

> Hi Greg,
> 
> On Wed, Jan 28, 2009 at 05:37:21PM +1000, Greg Ungerer wrote:
> > Hi Sascha,
> >
> > Sascha Hauer wrote:
> >> Sorry guys, sending this again. Of course I'm not 'y', just playing
> >> git-send-email:
> >>
> >> Who should the emails appear to be from? [Sascha Hauer <s.hauer@pengutronix.de>] y[es]
> >> Emails will be sent from: y
> >>
> >>
> >> These patches are an updated version from the ones I posted some time ago.
> >> They give the FEC ethernet driver a facelift and turn it into a
> >> platform_device driver. The Coldfire cores are still supported through
> >> legacy ifdefs. The platform driver support has been tested on a
> >> Freescale i.MX27 SoC.
> >
> > Outside of the one patch I commented on the series applies, runs and
> > seems to work OK on the ColdFire parts I tried it on.
> 
> Thanks for testing the patches. I'll add the change you mentioned.
> So this means I can add your Acked-by and send a pull request, well to
> whom? David Miller, Jeff Garzik?

Just send it to netdev and CC: me.
