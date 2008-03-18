From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: NEWEMAC: Support for Pause packets in EMAC driver
Date: Mon, 17 Mar 2008 22:56:06 -0500
Message-ID: <20080317225606.79f77502@zod.rchland.ibm.com>
References: <1205488348-22536-1-git-send-email-sr@denx.de>
	<47DE5F43.80604@garzik.org>
	<1205789101.26869.181.camel@pasglop>
	<1205789205.26869.184.camel@pasglop>
	<20080317164341.12075616@zod.rchland.ibm.com>
	<1205790747.26869.187.camel@pasglop>
	<47DEF159.3020504@garzik.org>
	<20080317200855.2954971a@zod.rchland.ibm.com>
	<1205808100.26869.204.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Stefan Roese <sr@denx.de>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Valentine Barshak <vbarshak@ru.mvista.com>
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:42608 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751030AbYCRD44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 23:56:56 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2I3utxi017617
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 23:56:55 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2I3utMe249056
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 23:56:55 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2I3uscW019128
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 23:56:55 -0400
In-Reply-To: <1205808100.26869.204.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Mar 2008 13:41:40 +1100
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> 
> > http://marc.info/?l=linux-netdev&m=120449748701492&w=2
> > 
> > I sent it to Ben with netdev on CC because you asked the various people
> > sending NEWEMAC patches to you to find a single person.
> > 
> > So from now on, what are we going to do?  It seems we're playing net
> > maintainer russian roulette for NEWEMAC and it's getting old.
> 
> I'm happy to collect the patches. I said I would do it, I was just taken
> aback a bit by Jeff suddenly merging two of Stefan patches directly :-)
> 
> I was actually planning this week to post a serie of all the pending
> EMAC patches for final review.

Ok.  Either way, if it helps someone I'd be happy to roll them into a
newemac branch in my git tree.

josh
