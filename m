From: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Subject: Re: [PATCH v2 0/3] net/macb: fixes to use core on Zynq SoCs
Date: Thu, 28 Mar 2013 12:28:11 +0100
Message-ID: <20130328112811.GA32161@pengutronix.de>
References: <1364461627-26521-1-git-send-email-s.trumtrar@pengutronix.de>
 <51542531.9010300@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38368 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754918Ab3C1L2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 07:28:16 -0400
Content-Disposition: inline
In-Reply-To: <51542531.9010300@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 28, 2013 at 12:10:41PM +0100, Nicolas Ferre wrote:
> On 03/28/2013 10:07 AM, Steffen Trumtrar :
> > Hi!
> > 
> > The Cadence GEM is also licensed for the Xilinx Zynq7000 SoCs.
> > As Xilinx uses other reset defaults, some fixes are necessary to have it
> > working there. And as the Zynq is dualcore, the clk_enables/disables now need
> > to be atomic.
> > 
> > Changes in v2:
> > 	- only 3/3 was changed to correctly use the atomic clk_[en|dis]able
> > 
> > Regards,
> > Steffen
> 
> On the whole series:
> 
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> 
> Thanks, best regards.
> 

Thanks,
Steffen

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
