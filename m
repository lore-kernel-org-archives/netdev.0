From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: FEC Patches
Date: Thu, 29 Jan 2009 10:03:45 +0100
Message-ID: <20090129090345.GG8446@pengutronix.de>
References: <1233052804-31228-1-git-send-email-s.hauer@pengutronix.de> <49800B31.9020608@snapgear.com> <20090128185339.GD8446@pengutronix.de> <20090128.123110.120011613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gerg@snapgear.com, netdev@vger.kernel.org, fred.rodo@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48065 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbZA2JDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 04:03:49 -0500
Content-Disposition: inline
In-Reply-To: <20090128.123110.120011613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 28, 2009 at 12:31:10PM -0800, David Miller wrote:
> From: Sascha Hauer <s.hauer@pengutronix.de>
> Date: Wed, 28 Jan 2009 19:53:39 +0100
> 
> > Hi Greg,
> > 
> > On Wed, Jan 28, 2009 at 05:37:21PM +1000, Greg Ungerer wrote:
> > > Hi Sascha,
> > >
> > > Sascha Hauer wrote:
> > >> Sorry guys, sending this again. Of course I'm not 'y', just playing
> > >> git-send-email:
> > >>
> > >> Who should the emails appear to be from? [Sascha Hauer <s.hauer@pengutronix.de>] y[es]
> > >> Emails will be sent from: y
> > >>
> > >>
> > >> These patches are an updated version from the ones I posted some time ago.
> > >> They give the FEC ethernet driver a facelift and turn it into a
> > >> platform_device driver. The Coldfire cores are still supported through
> > >> legacy ifdefs. The platform driver support has been tested on a
> > >> Freescale i.MX27 SoC.
> > >
> > > Outside of the one patch I commented on the series applies, runs and
> > > seems to work OK on the ColdFire parts I tried it on.
> > 
> > Thanks for testing the patches. I'll add the change you mentioned.
> > So this means I can add your Acked-by and send a pull request, well to
> > whom? David Miller, Jeff Garzik?
> 
> Just send it to netdev and CC: me.

Done, thanks

  Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
