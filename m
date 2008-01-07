From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] METH: fix MAC address handling
Date: Sun, 06 Jan 2008 17:20:18 -0800 (PST)
Message-ID: <20080106.172018.39803221.davem@davemloft.net>
References: <20080105224842.78EDCC2EFB@solo.franken.de>
	<20080106.002305.99653155.davem@davemloft.net>
	<20080106113815.GA6140@alpha.franken.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	ralf@linux-mips.org, jgarzik@pobox.com
To: tsbogend@alpha.franken.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48014
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752075AbYAGBUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2008 20:20:19 -0500
In-Reply-To: <20080106113815.GA6140@alpha.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Date: Sun, 6 Jan 2008 12:38:16 +0100

> On Sun, Jan 06, 2008 at 12:23:05AM -0800, David Miller wrote:
> > I know that this whole driver is full of assumptions about
> > the endianness of the system this chip is found on, so
> > I'm only interested in if the transformation is equivalent
> > and the driver will keep working properly.
> 
> I've tested the driver and it's still working :-)

Great :)
