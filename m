From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: NEWEMAC: Support for Pause packets in EMAC driver
Date: Mon, 17 Mar 2008 16:43:41 -0500
Message-ID: <20080317164341.12075616@zod.rchland.ibm.com>
References: <1205488348-22536-1-git-send-email-sr@denx.de>
	<47DE5F43.80604@garzik.org>
	<1205789101.26869.181.camel@pasglop>
	<1205789205.26869.184.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Stefan Roese <sr@denx.de>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Valentine Barshak <vbarshak@ru.mvista.com>
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:54133 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686AbYCQVo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 17:44:29 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2HLhKHR028317
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 17:43:20 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2HLiSeq206194
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 15:44:28 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2HLiQ0w004555
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2008 15:44:27 -0600
In-Reply-To: <1205789205.26869.184.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Mar 2008 08:26:45 +1100
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> 
> On Tue, 2008-03-18 at 08:25 +1100, Benjamin Herrenschmidt wrote:
> > > > 
> > > > Signed-off-by: Pravin M. Bathija <pbathija@amcc.com>
> > > > Signed-off-by: Stefan Roese <sr@denx.de>
> > > > ---
> > > >  drivers/net/ibm_newemac/core.c |    7 +++++++
> > > >  1 files changed, 7 insertions(+), 0 deletions(-)
> > > 
> > > applied
> > 
> > Thanks. There's also a couple of patches from Valentine that should go
> > in. I'll ask him to resend to you.
> 
> Actually, they need some arch bits so they are better off going through
> Josh tree on top of the said changes.

There's also the section mismatch patch I sent you.  I don't care who's
tree they go through, but I'd need to know either way so keep me in the
loop please.

josh
