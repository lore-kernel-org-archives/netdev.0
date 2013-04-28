From: Robert Schwebel <r.schwebel@pengutronix.de>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable
 call"
Date: Sun, 28 Apr 2013 19:27:24 +0200
Message-ID: <20130428172724.GC1366@pengutronix.de>
References: <20130426134415.GS1366@pengutronix.de>
 <20130426.143309.1011152996477262852.davem@davemloft.net>
 <20130427090545.GY1366@pengutronix.de>
 <20130428.011144.1722290947259121116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lznuaa@gmail.com, l.stach@pengutronix.de, netdev@vger.kernel.org,
	Frank.Li@freescale.com, festevam@gmail.com, shawn.guo@linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54439 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977Ab3D1R12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 13:27:28 -0400
Content-Disposition: inline
In-Reply-To: <20130428.011144.1722290947259121116.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 28, 2013 at 01:11:44AM -0400, David Miller wrote:
> > Please consider to merge the reverts. Otherwhise FEC will be broken
> > in 3.9.
>
> The amount of effort you put into this email, and complaining,
> far exceed that necessary to help Frank write a fix.
>
> I've already told you how I want to see this resolved, and you
> haven't given me any new information, so my point of view has
> not changed.

Ok, so 3.9 will be broken - it's your decision. We'll have a lot of time
to fix things properly then; Lucas will test & comment the new patches
next week then.

rsc
-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
