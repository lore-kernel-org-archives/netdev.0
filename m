From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: NEWEMAC: Support for Pause packets in EMAC driver
Date: Tue, 18 Mar 2008 10:55:32 +1100
Message-ID: <1205798132.26869.191.camel@pasglop>
References: <1205488348-22536-1-git-send-email-sr@denx.de>
	 <47DE5F43.80604@garzik.org> <1205789101.26869.181.camel@pasglop>
	 <1205789205.26869.184.camel@pasglop>
	 <20080317164341.12075616@zod.rchland.ibm.com>
	 <1205790747.26869.187.camel@pasglop>  <47DEF159.3020504@garzik.org>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Josh Boyer <jwboyer@linux.vnet.ibm.com>, Stefan Roese <sr@denx.de>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Valentine Barshak <vbarshak@ru.mvista.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48802 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752284AbYCRAHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 20:07:48 -0400
In-Reply-To: <47DEF159.3020504@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-03-17 at 18:31 -0400, Jeff Garzik wrote:
> > Jeff, do you mind if we get those patches through the powerpc tree ?
> > EMAC is very powerpc specific and these are mostly internal driver
> > cuisine.
> 
> Fine with me in concept, though I haven't seen the patches in
> question.

Yup, I've asked people to copy you on them so you get a chance to ack
them :-)

Cheers,
Ben.


