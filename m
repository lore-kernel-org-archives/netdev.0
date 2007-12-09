From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/11] ibm_newemac: Add BCM5248 and Marvell 88E1111 PHY
	support
Date: Sun, 09 Dec 2007 18:08:15 +1100
Message-ID: <1197184095.6572.21.camel@pasglop>
References: <20071205001534.D681ADDF2D@ozlabs.org>
	 <4759A870.8030900@pobox.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60653 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750948AbXLIHJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Dec 2007 02:09:24 -0500
In-Reply-To: <4759A870.8030900@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2007-12-07 at 15:09 -0500, Jeff Garzik wrote:
> Benjamin Herrenschmidt wrote:
> > From: Stefan Roese <sr@denx.de>
> > 
> > This patch adds BCM5248 and Marvell 88E1111 PHY support to NEW EMAC driver.
> > These PHY chips are used on PowerPC 440EPx boards.
> > The PHY code is based on the previous work by Stefan Roese <sr@denx.de>
> > 
> > Signed-off-by: Stefan Roese <sr@denx.de>
> > Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
> > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > ---
> > 
> >  drivers/net/ibm_newemac/phy.c |   39 +++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 39 insertions(+)
> 
> applied 1-11 #upstream-fixes

Thanks !

Cheers,
Ben.


