From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH 2/11] ibm_newemac: Add ET1011c PHY support
Date: Fri, 30 Nov 2007 15:30:17 -0600
Message-ID: <20071130213017.GA10440@lixom.net>
References: <1196401223.5661.297518056501.qpush@grosgo> <20071130054126.E3EFADDE0C@ozlabs.org> <20071130142904.GC3117@lixom.net> <1196456356.13230.104.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:50849 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756224AbXK3V0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 16:26:50 -0500
Content-Disposition: inline
In-Reply-To: <1196456356.13230.104.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 01, 2007 at 07:59:16AM +1100, Benjamin Herrenschmidt wrote:
> 
> On Fri, 2007-11-30 at 08:29 -0600, Olof Johansson wrote:
> > Hi,
> > 
> > On Fri, Nov 30, 2007 at 04:40:24PM +1100, Benjamin Herrenschmidt wrote:
> > 
> > > This adds support for the Agere ET1011c PHY as found on the AMCC Taishan
> > > board.
> > 
> > The whole patch has whitespace messed up (tabs vs spaces).
> 
> Thanks for noticing it on the ...3rd time those are sent to the list...

Yeah, sorry about that. Should have caught it sooner.

Anyway, can be fixed up with incremental patch, doesn't need to hold up
the whole series.


-Olof
