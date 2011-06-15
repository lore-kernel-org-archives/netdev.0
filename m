From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH v2 1/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Wed, 15 Jun 2011 12:21:37 +0200
Message-ID: <20110615102137.GQ11275@wantstofly.org>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
 <20110605083445.GT16318@ibawizard.net>
 <20110605085948.GB16018@acer>
 <20110605.140801.1144137337172959622.davem@davemloft.net>
 <20110606172607.GB3082@acer>
 <ADE657CA350FB648AAC2C43247A983F001F381FC56CE@AUSP01VMBX24.collaborationhost.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mika Westerberg <mika.westerberg@iki.fi>,
	"ynezz@true.cz" <ynezz@true.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ryan@bluewatersys.com" <ryan@bluewatersys.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:51461 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754167Ab1FOKSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 06:18:45 -0400
Content-Disposition: inline
In-Reply-To: <ADE657CA350FB648AAC2C43247A983F001F381FC56CE@AUSP01VMBX24.collaborationhost.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 06, 2011 at 12:48:19PM -0500, H Hartley Sweeten wrote:

> Lennert,

Hi,


> You are listed as the maintainer for these EP93xx related pieces:
> 
> ARM/CIRRUS LOGIC EDB9315A MACHINE SUPPORT
> CIRRUS LOGIC EP93XX ETHERNET DRIVER
> CIRRUS LOGIC EP93XX OHCI USB HOST DRIVER
> 
> I can take over the edb9315a with no problem.  It actually falls under
> arch/arm/mach-ep93xx, so the entry could just be removed from MAINTAINERS.

If you have the hardware, that's fine with me.


> For the OHCI driver, I'm in the same boat as the Ethernet.  If you are
> no longer maintaining this driver I'm willing to handle it but would
> like someone to step up as a co-maintainer.  Hopefully someone that
> has some grasp of that subsystem.

Same here.


> Your also listed in the source as the maintainer of these ep93xx boards:
> 
> ADSSPHERE	adssphere.c
> EDB9302A	edb93xx.c
> EDB9315	edb93xx.c
> EDB9315A	edb93xx.c
> GESBC9312	gesbc9312.c
> TS72XX	ts72xx.c
> 
> I'm willing to handle those also since they are under arch/arm/mach-ep93xx.

Do you have all these boards, though?


thanks,
Lennert
