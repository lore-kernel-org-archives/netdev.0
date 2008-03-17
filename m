From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: NEWEMAC: Support for Pause packets in EMAC driver
Date: Tue, 18 Mar 2008 08:26:45 +1100
Message-ID: <1205789205.26869.184.camel@pasglop>
References: <1205488348-22536-1-git-send-email-sr@denx.de>
	 <47DE5F43.80604@garzik.org>  <1205789101.26869.181.camel@pasglop>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stefan Roese <sr@denx.de>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jwboyer@linux.vnet.ibm.com,
	Valentine Barshak <vbarshak@ru.mvista.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:49136 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752791AbYCQV2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 17:28:32 -0400
In-Reply-To: <1205789101.26869.181.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-03-18 at 08:25 +1100, Benjamin Herrenschmidt wrote:
> > > 
> > > Signed-off-by: Pravin M. Bathija <pbathija@amcc.com>
> > > Signed-off-by: Stefan Roese <sr@denx.de>
> > > ---
> > >  drivers/net/ibm_newemac/core.c |    7 +++++++
> > >  1 files changed, 7 insertions(+), 0 deletions(-)
> > 
> > applied
> 
> Thanks. There's also a couple of patches from Valentine that should go
> in. I'll ask him to resend to you.

Actually, they need some arch bits so they are better off going through
Josh tree on top of the said changes.

Valentine, can you make sure Jeff at least has a chance to see them and
ack them though ?

Cheers,
Ben.


