From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 6/9] fs_enet: Be an of_platform device when CONFIG_PPC_CPM_NEW_BINDING is set.
Date: Fri, 7 Mar 2008 10:37:47 -0600
Message-ID: <20080307163747.GF10545@ld0162-tx32.am.freescale.net>
References: <20070920220121.GF28784@loki.buserror.net> <200802151350.20627.laurentp@cse-semaphore.com> <1203089936.20350.7.camel@p60365-ste> <200803071623.42519.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergej Stepanov <Sergej.Stepanov@ids.de>, linuxppc-dev@ozlabs.org,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:32812 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbYCGQiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 11:38:55 -0500
Content-Disposition: inline
In-Reply-To: <200803071623.42519.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 07, 2008 at 04:23:39PM +0100, Laurent Pinchart wrote:
> Hi Sergej,
> 
> On Friday 15 February 2008 16:38, Sergej Stepanov wrote:
> > Am Freitag, den 15.02.2008, 13:50 +0100 schrieb Laurent Pinchart:
> > > We're loosing the possibility of having MDC and MDIO on different ports.
> > > This is quite easy to fix for the non-CONFIG_PPC_CPM_NEW_BINDING case but
> > > I'm not familiar with OF bindings (yet) to fix the
> > > CONFIG_PPC_CPM_NEW_BINDING case.
> >
> > for OF issue i had this for a paar month:
> > http://www.spinics.net/lists/netdev/msg45778.html
> > http://www.spinics.net/lists/netdev/msg47159.html
> > i'll be glad if it helps...
> 
> Could these be applied ? Any showstopper ?

Acked-by: Scott Wood <scottwood@freescale.com>, if I haven't already.

-Scott
