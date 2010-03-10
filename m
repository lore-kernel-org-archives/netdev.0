From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add ColdFire support to the smc91x driver
Date: Wed, 10 Mar 2010 07:33:05 -0800 (PST)
Message-ID: <20100310.073305.196426430.davem@davemloft.net>
References: <201003090703.o2973pbP013668@goober.internal.moreton.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@fluxnic.net, gerg@uclinux.org, netdev@vger.kernel.org
To: gerg@snapgear.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41013
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754002Ab0CJPcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 10:32:45 -0500
In-Reply-To: <201003090703.o2973pbP013668@goober.internal.moreton.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Ungerer <gerg@snapgear.com>
Date: Tue, 9 Mar 2010 17:03:51 +1000

> net: add ColdFire support to the smc91x driver
> 
> Some embedded ColdFire based boards use the SMC 91x family of ethernet
> devices. (For example the Freescale M5249C3 and MoretonBay NETtel).
> 
> Add IO access support to the SMC91x driver, and allow this driver to
> be configured for ColdFire platforms.
> 
> Signed-off-by: Greg Ungerer <gerg@uclinux.org>

Applied.
