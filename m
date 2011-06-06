From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: Re: [PATCH v2 1/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Mon, 6 Jun 2011 20:26:07 +0300
Message-ID: <20110606172607.GB3082@acer>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
 <20110605083445.GT16318@ibawizard.net>
 <20110605085948.GB16018@acer>
 <20110605.140801.1144137337172959622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ynezz@true.cz, netdev@vger.kernel.org,
	hsweeten@visionengravers.com, ryan@bluewatersys.com,
	kernel@wantstofly.org, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:48474 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755357Ab1FFR20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 13:28:26 -0400
Received: by eyx24 with SMTP id 24so1437087eyx.19
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 10:28:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110605.140801.1144137337172959622.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 05, 2011 at 02:08:01PM -0700, David Miller wrote:
> From: Mika Westerberg <mika.westerberg@iki.fi>
> Date: Sun, 5 Jun 2011 11:59:48 +0300
> 
> > It looks like David Miller (CC'd) has been taking care of ep93xx_eth.c maybe
> > he knows this better.
> 
> Someone needs to step up and take over as the real maintainer of this
> driver.  The way the driver is currently being hacked on is
> unsustainable.

Can't agree more.

Hartley, Ryan: do you have any preferences? Are you guys already overwhelmed
with your current maintenance work, or could you consider taking this one as
well? 

If no one else steps up, I can volunteer but I have to admit that I don't know
much about that driver.
