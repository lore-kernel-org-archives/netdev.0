From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: NEWEMAC: Support for Pause packets in EMAC driver
Date: Mon, 17 Mar 2008 20:08:55 -0500
Message-ID: <20080317200855.2954971a@zod.rchland.ibm.com>
References: <1205488348-22536-1-git-send-email-sr@denx.de>
	<47DE5F43.80604@garzik.org>
	<1205789101.26869.181.camel@pasglop>
	<1205789205.26869.184.camel@pasglop>
	<20080317164341.12075616@zod.rchland.ibm.com>
	<1205790747.26869.187.camel@pasglop>
	<47DEF159.3020504@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, Stefan Roese <sr@denx.de>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Valentine Barshak <vbarshak@ru.mvista.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:36014 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754350AbYCRBJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 21:09:46 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2I19jOn004609
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 21:09:45 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2I19j9u221138
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 19:09:45 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2I19hoD018769
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 19:09:45 -0600
In-Reply-To: <47DEF159.3020504@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Mar 2008 18:31:53 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Benjamin Herrenschmidt wrote:
> >> There's also the section mismatch patch I sent you.  I don't care who's
> >> tree they go through, but I'd need to know either way so keep me in the
> >> loop please.
> > 
> > Jeff, do you mind if we get those patches through the powerpc tree ?
> > EMAC is very powerpc specific and these are mostly internal driver
> > cuisine.
> 
> Fine with me in concept, though I haven't seen the patches in question.

http://marc.info/?l=linux-netdev&m=120449748701492&w=2

I sent it to Ben with netdev on CC because you asked the various people
sending NEWEMAC patches to you to find a single person.

So from now on, what are we going to do?  It seems we're playing net
maintainer russian roulette for NEWEMAC and it's getting old.

josh
